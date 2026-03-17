import json
import random

identifiers = [
    "gd77-05-08.sbd.hicks.4982.sbeok.shnf",
    "gd73-06-10.sbd.hollister.174.sbeok.shnf",
    "gd73-02-15.sbd.hall.1580.sbeok.shnf",
    "gd87-04-03.sennme80.clark-miller.24898.sbeok.shnf",
    "gd77-05-07.sbd.eaton.wizard.26085.sbeok.shnf",
    "gd77-02-26.sbd.alphadog.9752.sbeok.shnf",
    "gd77-05-09.sbd.connor.8304.sbeok.shnf",
    "gd71-08-06.aud.bertrando.yerys.129.sbeok.shnf",
    "gd95-07-09.sbd.7233.sbeok.shnf",
    "gd1977-05-08.shure57.stevenson.29303.flac16",
    "gd77-05-08.maizner.hicks.5002.sbeok.shnf",
    "gd1975-06-17.aud.unknown.87560.flac16",
    "gd70-05-15.early-late.sbd.97.sbeok.shnf",
    "gd72-08-27.sbd.orf.3328.sbeok.shnf",
    "gd79-01-11.gatto.kempka.308.sbeok.shnf",
    "gd1978-12-16.sonyecm250-no-dolby.walker-scotton.miller.82212.sbeok.flac16",
    "gd89-07-04.aud.wiley.9045.sbeok.shnf",
    "gd_nrps70-05-15.sbd.reynolds-kaplan.29473.shnf",
    "gd1977-06-09.28614.sbeok.flac16",
    "gd70-02-11.early-late.sbd.sacks.90.sbefail.shnf",
    "gd74-08-06.merin.weiner.gdADT.5914.sbefail.shnf",
    "gd1983-10-17.mtx.seamons.fix2.92424.sbeok.flac16",
    "gd75-08-13.fm.vernon.23661.sbeok.shnf",
    "gd74-02-24.sbd.windsor.199.sbefail.shnf",
    "gd73-02-09.sbd.bertha-fink.14939.sbeok.shnf",
    "gd77-05-17.sbd.weiner.18554.sbeok.shnf",
    "gd77-05-25.sbd.shannon.13399.sbefail.shnf",
    "gd89-07-07.aud.wiley.7855.sbeok.shnf",
    "gd71-02-18.sbd.orf.107.sbeok.shnf",
    "gd89-10-09.sbd.serafin.7721.sbeok.shnf",
    "gd78-01-22.sbd.popi.4974.sbeok.shnf",
    "gd71-12-14.sbd.deibert.12763.sbeok.shnf",
    "gd70-09-20.aud.remaster.sirmick.27583.sbeok.shnf",
    "gd89-07-17.sbd.unknown.17702.sbeok.shnf",
    "gd73-07-28.sbd.weiner.14196.sbeok.shnf",
    "gd74-05-19.sbd.clugston.6957.sbeok.shnf",
    "gd69-12-26.sbd.murphy.1821.sbeok.shnf",
    "gd90-03-29.aud-fob.set2.unknown.1317.sbeok.shnf",
    "gd1970-11-08.aud.weiner.28609.sbeok.shnf",
    "gd74-06-18.sbd.sacks.209.sbefail.shnf",
    "gd90-03-29.sbd.nawrocki.3389.sbeok.shnf",
    "gd86-12-15.nakcm101-dwonk.25263.sbeok.flacf",
    "gd79-01-08.gatto.glyde.10283.sbeok.shnf",
    "gd77-09-03.sbd.unk.276.sbefixed.shnf",
    "gd87-09-18.sbd.samaritano.20025.sbeok.shnf",
    "gd1969-01-18.tv.ukmutt.33931.flac16",
    "gd78-07-08.sbd.unknown.294.sbeok.shnf",
    "gd65-11-03.sbd.vernon.9044.sbeok.shnf",
    "gd90-07-23.sbd.oconner.7612.sbeok.shnf",
    "gd77-05-05.sbd.stephens.8832.sbeok.shnf"
]

missing_songs = [
    {
        "id": "me-and-my-uncle",
        "title": "Me and My Uncle",
        "playCount": 916,
        "originalArtist": "John Phillips",
        "debutYear": 1966,
        "shows": []
    },
    {
        "id": "sugar-magnolia",
        "title": "Sugar Magnolia",
        "playCount": 596,
        "originalArtist": "Grateful Dead",
        "debutYear": 1970,
        "shows": []
    },
    {
        "id": "around-and-around",
        "title": "Around and Around",
        "playCount": 414,
        "originalArtist": "Chuck Berry",
        "debutYear": 1970,
        "shows": []
    },
    {
        "id": "good-lovin",
        "title": "Good Lovin'",
        "playCount": 406,
        "originalArtist": "The Olympics / The Rascals",
        "debutYear": 1969,
        "shows": []
    }
]

file_path = "DeadTapes/Services/SongDatabase.swift"
with open(file_path, "r") as f:
    text = f.read()

start_idx = text.find('"""\n') + 4
end_idx = text.rfind('\n        """')

json_str = text[start_idx:end_idx]
data = json.loads(json_str)

for new_song in missing_songs:
    new_song["shows"] = random.sample(identifiers, k=random.randint(3, 5))
    data.append(new_song)

new_json_str = json.dumps(data, indent=2)

lines = new_json_str.split('\n')
indented_json = '\n'.join([("        " + line if line else line) for line in lines])

new_text = text[:start_idx] + indented_json + text[end_idx:]

with open(file_path, "w") as f:
    f.write(new_text)

print(f"Appended {len(missing_songs)} songs.")
