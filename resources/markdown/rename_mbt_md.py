#!/usr/bin/env python3
"""
Script to rename files from .mbt.md extension to .md extension.
This script finds all files ending with .mbt.md in the current directory
and its subdirectories, then renames them to have .md extension instead.
"""

import os
import sys
from pathlib import Path


def rename_mbt_md_files(directory="."):
    """
    Rename all .mbt.md files to .md files in the given directory and subdirectories.
    
    Args:
        directory (str): The directory to search in (default: current directory)
    """
    directory_path = Path(directory)
    
    if not directory_path.exists():
        print(f"Error: Directory '{directory}' does not exist.")
        return False
    
    # Find all .mbt.md files recursively
    mbt_md_files = list(directory_path.rglob("*.mbt.md"))
    
    if not mbt_md_files:
        print("No .mbt.md files found.")
        return True
    
    print(f"Found {len(mbt_md_files)} .mbt.md file(s):")
    
    renamed_count = 0
    errors = []
    
    for file_path in mbt_md_files:
        # Create new filename by replacing .mbt.md with .md
        new_path = file_path.with_suffix("").with_suffix(".md")
        
        print(f"  {file_path} -> {new_path}")
        
        try:
            # Check if target file already exists
            if new_path.exists():
                print(f"    Warning: Target file '{new_path}' already exists. Skipping.")
                errors.append(f"Target exists: {new_path}")
                continue
            
            # Rename the file
            file_path.rename(new_path)
            renamed_count += 1
            print(f"    ✓ Renamed successfully")
            
        except Exception as e:
            error_msg = f"Failed to rename {file_path}: {e}"
            print(f"    ✗ Error: {e}")
            errors.append(error_msg)
    
    print(f"\nSummary:")
    print(f"  Files found: {len(mbt_md_files)}")
    print(f"  Files renamed: {renamed_count}")
    print(f"  Errors: {len(errors)}")
    
    if errors:
        print(f"\nErrors encountered:")
        for error in errors:
            print(f"  - {error}")
        return False
    
    return True


def main():
    """Main function to handle command line arguments and execute the rename operation."""
    
    # Handle command line arguments
    if len(sys.argv) > 2:
        print("Usage: python rename_mbt_md.py [directory]")
        print("  directory: Optional directory to search in (default: current directory)")
        sys.exit(1)
    
    directory = sys.argv[1] if len(sys.argv) == 2 else "."
    
    print(f"Renaming .mbt.md files to .md in directory: {os.path.abspath(directory)}")
    print("-" * 60)
    
    success = rename_mbt_md_files(directory)
    
    if success:
        print("\nOperation completed successfully!")
        sys.exit(0)
    else:
        print("\nOperation completed with errors!")
        sys.exit(1)


if __name__ == "__main__":
    main()