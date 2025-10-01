import os

# ==== CONFIG ====
OUTPUT_FILE = "Lib_SourceCodeDump.txt"  # <- change this to whatever filename you want
# ================

base_dir = os.path.dirname(os.path.abspath(__file__))
script_path = os.path.abspath(__file__)
output_path = os.path.join(base_dir, OUTPUT_FILE)
firebase_options_path = os.path.join(base_dir, "firebase_options.dart")

with open(output_path, "w", encoding="utf-8") as out:
  out.write(f"// Source code dump of all files in {base_dir}\n\n")
  for root, _, files in os.walk(base_dir):
    for file in files:
      path = os.path.join(root, file)

      # Skip the script itself and the output file
      if os.path.abspath(path) in [script_path, output_path, firebase_options_path]:
        continue

      rel_path = os.path.relpath(path, base_dir)
      out.write(f"// {rel_path}\n")
      try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
          out.write(f.read())
      except:
        out.write("[[binary or unreadable file skipped]]")
      out.write("\n\n")