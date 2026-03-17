require 'xcodeproj'

project_path = 'DeadTapes.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

removed_count = 0

target.resources_build_phase.files.dup.each do |build_file|
  ref = build_file.file_ref
  if ref
    puts "Checking resource: #{ref.path} (name: #{ref.name})"
    if (ref.path && ref.path.include?('Contents.json')) || (ref.name && ref.name.include?('Contents.json'))
      puts "--> Removing #{ref.path || ref.name}!"
      ref.remove_from_project
      removed_count += 1
    end
  end
end

if removed_count > 0
  project.save
  puts "Project updated successfully! Removed #{removed_count} references."
else
  puts "No matching references found."
end
