{ pkgs ? import <nixpkgs> {} }:

let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    # openai-whisper
    # pyannote-audio
    # torch
    # transformers
    (
      buildPythonPackage rec {
        pname = "ffmpeg-python";
        version = "0.2.0";
        src = fetchPypi {
          inherit pname version;
          sha256 = "sha256-65oF3E4uGTt4TY4AihaZp82aJDfSH5hnNQCTqrZFJFc=";
        };
        doCheck = false;
        propagatedBuildInputs = [ future ];
      }
    )
  ]);
in
pkgs.writeScriptBin "transkripsi" ''
  #!${pkgs.python3}/bin/python

  import sys
  import os
  import argparse
  from pathlib import Path
  import torch
  import whisper
  from pyannote.audio import Pipeline

  def process_audio(args):
      # Inisialisasi pipeline diarization
      pipeline = Pipeline.from_pretrained(
          "pyannote/speaker-diarization",
          use_auth_token="YOUR_HUGGINGFACE_TOKEN"  # Ganti dengan token Anda
      )

      # Load model Whisper
      print(f"Loading model {args.model}...")
      model = whisper.load_model(args.model)

      # Buat direktori output
      output_dir = Path("Hasil_Transkripsi")
      output_dir.mkdir(exist_ok=True)

      # Proses diarization
      print("Mengidentifikasi pembicara...")
      diarization = pipeline(args.file)

      # Transkripsi dengan Whisper
      print("Melakukan transkripsi...")
      result = model.transcribe(args.file, language=args.language)

      # Gabungkan hasil diarization dengan transkripsi
      segments = []
      for turn, _, speaker in diarization.itertracks(yield_label=True):
          start = turn.start
          end = turn.end
          
          # Cari teks yang sesuai dengan timestamp
          text_segments = [
              seg for seg in result["segments"]
              if seg["start"] <= end and seg["end"] >= start
          ]
          
          text = " ".join([seg["text"] for seg in text_segments])
          segments.append({
              "speaker": speaker,
              "start": start,
              "end": end,
              "text": text
          })

      # Simpan hasil
      base_name = Path(args.file).stem
      
      # Format TXT
      if args.format in ['txt', 'all']:
          txt_path = output_dir / f"{base_name}.txt"
          with open(txt_path, 'w', encoding='utf-8') as f:
              for seg in segments:
                  f.write(f"[{seg['speaker']}] {seg['text']}\n\n")

      # Format SRT
      if args.format in ['srt', 'all']:
          srt_path = output_dir / f"{base_name}.srt"
          with open(srt_path, 'w', encoding='utf-8') as f:
              for i, seg in enumerate(segments, 1):
                  start_time = format_timestamp(seg['start'])
                  end_time = format_timestamp(seg['end'])
                  f.write(f"{i}\n")
                  f.write(f"{start_time} --> {end_time}\n")
                  f.write(f"{seg['speaker']}: {seg['text']}\n\n")

      # Format VTT
      if args.format in ['vtt', 'all']:
          vtt_path = output_dir / f"{base_name}.vtt"
          with open(vtt_path, 'w', encoding='utf-8') as f:
              f.write("WEBVTT\n\n")
              for i, seg in enumerate(segments, 1):
                  start_time = format_timestamp(seg['start'], vtt=True)
                  end_time = format_timestamp(seg['end'], vtt=True)
                  f.write(f"{start_time} --> {end_time}\n")
                  f.write(f"<v {seg['speaker']}>{seg['text']}</v>\n\n")

      print(f"Transkripsi selesai! File disimpan di direktori {output_dir}")

  def format_timestamp(seconds, vtt=False):
      hours = int(seconds // 3600)
      minutes = int((seconds % 3600) // 60)
      secs = int(seconds % 60)
      msecs = int((seconds - int(seconds)) * 1000)
      
      if vtt:
          return f"{hours:02d}:{minutes:02d}:{secs:02d}.{msecs:03d}"
      else:
          return f"{hours:02d}:{minutes:02d}:{secs:02d},{msecs:03d}"

  def main():
      parser = argparse.ArgumentParser(description="Transkripsi audio dengan identifikasi pembicara")
      parser.add_argument("file", help="File audio untuk ditranskripsi")
      parser.add_argument("-m", "--model", default="base", 
                         choices=["tiny", "base", "small", "medium", "large"],
                         help="Model Whisper yang digunakan")
      parser.add_argument("-l", "--language", default=None,
                         help="Kode bahasa (en, id, dll)")
      parser.add_argument("-f", "--format", default="all",
                         choices=["txt", "srt", "vtt", "all"],
                         help="Format output")
      
      args = parser.parse_args()
      
      if not os.path.exists(args.file):
          print(f"Error: File {args.file} tidak ditemukan")
          sys.exit(1)
          
      process_audio(args)

  if __name__ == "__main__":
      main()
''
