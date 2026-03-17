import json
import urllib.request
import re

with open("DeadTapes/Services/SongDatabase.swift", "r") as f:
    text = f.read()

# Extract the JSON literal
start_idx = text.find('"""\n') + 4
end_idx = text.rfind('\n        """')
if start_idx == 3 or end_idx == -1:
    print("Could not find json literal")
    exit(1)

json_str = text[start_idx:end_idx]
data = json.loads(json_str)

date_cache = {}

for song in data:
    new_shows = []
    for show_id in song["shows"]:
        match = re.search(r'gd(?:19)?(\d{2,4}-\d{2}-\d{2})', show_id)
        if match:
            date_str = match.group(1)
            # standard full year
            if len(date_str) == 8:
                date_str = "19" + date_str
            
            if date_str not in date_cache:
                url = f"https://archive.org/advancedsearch.php?q=collection:GratefulDead+AND+date:{date_str}&fl[]=identifier&output=json&rows=10"
                req = urllib.request.Request(url)
                try:
                    res = urllib.request.urlopen(req)
                    res_json = json.loads(res.read().decode())
                    docs = res_json.get("response", {}).get("docs", [])
                    valid_id = None
                    for doc in docs:
                        if "sbd" in doc.get("identifier", "").lower():
                            valid_id = doc["identifier"]
                            break
                    if not valid_id and docs:
                        valid_id = docs[0]["identifier"]
                    date_cache[date_str] = valid_id
                    print(f"Mapped {date_str} to {valid_id}")
                except Exception as e:
                    print(f"Error for {date_str}: {e}")
                    date_cache[date_str] = None
            
            if date_cache[date_str]:
                new_shows.append(date_cache[date_str])
    
    # deduplicate, preserving sort somewhat
    seen = set()
    deduped = []
    for x in new_shows:
        if x not in seen:
            deduped.append(x)
            seen.add(x)
    song["shows"] = deduped

new_json_str = json.dumps(data, indent=2)
# Apply swift indentation
lines = new_json_str.split('\n')
indented_json = '\n'.join([("        " + line if line else line) for line in lines])

new_text = text[:start_idx] + indented_json + text[end_idx:]

with open("DeadTapes/Services/SongDatabase.swift", "w") as f:
    f.write(new_text)

print("Done")
