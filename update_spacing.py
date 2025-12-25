#!/usr/bin/env python3
import os
import re
from pathlib import Path

# Find all Dart files in lib/features that reference AppConstants.spacing
root = Path("lib/features")
pattern = re.compile(r'AppConstants\.spacing([A-Z][a-z]*)')
spacing_map = {
    'XL': 'xxl',
    'Xl': 'xxl',
    'L': 'lg',
    'M': 'md',
    'S': 'sm',
    'Xs': 'xs',
}

for dart_file in root.rglob("*.dart"):
    content = dart_file.read_text(encoding='utf-8')
    
    # Check if file has AppConstants.spacing
    if 'AppConstants.spacing' not in content:
        continue
    
    # Check if app_spacing is already imported
    if 'app_spacing' not in content:
        # Add import after app_constants import
        lines = content.split('\n')
        new_lines = []
        added = False
        for line in lines:
            new_lines.append(line)
            if not added and 'app_constants' in line:
                new_lines.append(line.replace('app_constants', 'app_spacing'))
                added = True
        content = '\n'.join(new_lines)
    
    # Replace all AppConstants.spacing* with AppSpacing.*
    def replace_spacing(match):
        size = match.group(1)
        mapped = spacing_map.get(size, size.lower())
        return f'AppSpacing.{mapped}'
    
    new_content = pattern.sub(replace_spacing, content)
    
    if new_content != content:
        dart_file.write_text(new_content, encoding='utf-8')
        print(f"Updated: {dart_file}")

print("✅ Done!")
