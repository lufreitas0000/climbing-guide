import json
import os
import argparse
import segno
import sys

def main():
    parser = argparse.ArgumentParser(description="Generate QR codes from LuaLaTeX JSON manifest.")
    parser.add_argument("--manifest", required=True, help="Path to the qrcodes_manifest.json")
    parser.add_argument("--outdir", required=True, help="Target directory for generated PDF files")
    args = parser.parse_args()

    if not os.path.exists(args.manifest):
        print(f"QR Generator: Manifest '{args.manifest}' not found. Skipping.")
        sys.exit(0)

    try:
        with open(args.manifest, 'r') as f:
            registry = json.load(f)
    except json.JSONDecodeError:
        print("QR Generator: Invalid JSON manifest. Skipping.")
        sys.exit(0)

    os.makedirs(args.outdir, exist_ok=True)
    generated_count = 0

    for entry in registry:
        filepath = os.path.join(args.outdir, entry['filename'])
        
        # Idempotency check: only generate if the file does not exist
        if not os.path.exists(filepath):
            # Level 'q' enforces 25% Error Correction
            qr = segno.make(entry['url'], error='q')
            qr.save(filepath)
            generated_count += 1
            
    skipped = len(registry) - generated_count
    print(f"QR Generator: {generated_count} new PDFs generated, {skipped} skipped (idempotent).")

if __name__ == "__main__":
    main()
