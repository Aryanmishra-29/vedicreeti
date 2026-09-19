import os
import re

lib_dir = r"d:\vedicreeti\lib"

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith(".dart") and file != "main.dart" and file != "fix_theme.dart":
            file_path = os.path.join(root, file)
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()

            original = content
            # Replace const Color(0xFFFAF7F2) -> Theme.of(context).scaffoldBackgroundColor
            content = re.sub(r'const\s+Color\(0xFFFAF7F2\)', 'Theme.of(context).scaffoldBackgroundColor', content)
            content = re.sub(r'Color\(0xFFFAF7F2\)', 'Theme.of(context).scaffoldBackgroundColor', content)
            
            if original != content:
                print(f"Updated {file}")
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(content)

print("Replacement complete.")
