import os
import re

def update_headers(dir_path):
    # Regex to find the vertical bar container
    container_pattern = re.compile(
        r'(Container\(\s*width:\s*3,\s*height:\s*18,\s*decoration:\s*BoxDecoration\(\s*color:\s*const\s*Color\(0xFFC9A227\),\s*borderRadius:\s*BorderRadius\.circular\(2\),\s*\),\s*\))'
    )
    
    # Replacement for vertical bar
    new_container = """Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            )"""

    # Regex to find the text style that follows
    # We'll look for style: TextStyle(...) or const TextStyle(...) and replace color, fontWeight, letterSpacing
    # A generic approach: we can just find the color: Color(0xFF2A241D) or similar in the same row/column.
    
    # Let's just do a simpler search and replace for the style if it matches the header pattern
    # It's safer to just regex replace the specific text styles if they have color: Color(0xFF2A241D)
    
    text_style_pattern = re.compile(
        r'style:\s*(?:const\s*)?TextStyle\(\s*color:\s*(?:const\s*)?Color\(0xFF2A241D\),\s*fontSize:\s*14,\s*fontWeight:\s*FontWeight\.w600,(.*?)\)',
        re.DOTALL
    )

    for root, dirs, files in os.walk(dir_path):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = content
                if container_pattern.search(new_content):
                    new_content = container_pattern.sub(new_container, new_content)
                
                # Update text styles
                # We replace color to 0xFFFFD700, fontWeight to w700, letterSpacing to 1.2
                def style_replacer(match):
                    rest = match.group(1)
                    # remove old letter spacing if exists
                    rest = re.sub(r'letterSpacing:\s*[\d\.]+,\s*', '', rest)
                    return f"style: const TextStyle(\n                color: Color(0xFFFFD700),\n                fontSize: 14,\n                fontWeight: FontWeight.w700,\n                letterSpacing: 1.2,{rest})"
                
                new_content = text_style_pattern.sub(style_replacer, new_content)
                
                # Check for other variants like `fontSize: 18` or `fontSize: 16`
                text_style_pattern2 = re.compile(
                    r'style:\s*(?:const\s*)?TextStyle\(\s*color:\s*isDarkMode\s*\?\s*Colors\.white\s*:\s*const\s*Color\(0xFF2A241D\),\s*fontSize:\s*16,\s*fontWeight:\s*FontWeight\.w600,(.*?)\)',
                    re.DOTALL
                )
                def style_replacer2(match):
                    rest = match.group(1)
                    rest = re.sub(r'letterSpacing:\s*[\d\.]+,\s*', '', rest)
                    return f"style: const TextStyle(\n                color: Color(0xFFFFD700),\n                fontSize: 16,\n                fontWeight: FontWeight.w700,\n                letterSpacing: 1.2,{rest})"
                new_content = text_style_pattern2.sub(style_replacer2, new_content)

                if new_content != content:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Updated {file_path}")

if __name__ == '__main__':
    update_headers(r'c:\vedicreeti_v2\lib')
