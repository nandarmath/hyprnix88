{ pkgs ? import <nixpkgs> {} }:

pkgs.python3Packages.buildPythonApplication {
  pname = "audio2text";
  version = "0.1.0";
  
  src = pkgs.writeTextFile {
    name = "audio2text-script";
    destination = "/audio2text.py";
    text = ''
      #!/usr/bin/env python3
      import os
      import sys
      import speechrecognition as sr
      from pydub import AudioSegment

      def transcribe_audio(audio_path):
          recognizer = sr.Recognizer()
          
          file_extension = os.path.splitext(audio_path)[1].lower()
          
          if file_extension != '.wav':
              audio = AudioSegment.from_file(audio_path, format=file_extension[1:])
              audio.export("temp.wav", format="wav")
              audio_path = "temp.wav"
          
          try:
              with sr.AudioFile(audio_path) as source:
                  audio_data = recognizer.record(source)
                  
                  try:
                      text = recognizer.recognize_google(audio_data, language='id-ID')
                      return text
                  except sr.UnknownValueError:
                      return "Transkripsi gagal: Audio tidak dapat dikenali"
                  except sr.RequestError:
                      return "Transkripsi gagal: Masalah koneksi internet"
          
          except Exception as e:
              return f"Error: {str(e)}"
          
          finally:
              if file_extension != '.wav':
                  os.remove("temp.wav")

      def main():
          if len(sys.argv) != 3:
              print("Penggunaan: audio2text <input_audio> <output_text>")
              sys.exit(1)
          
          input_audio = sys.argv[1]
          output_text = sys.argv[2]
          
          hasil_transkrip = transcribe_audio(input_audio)
          
          with open(output_text, 'w', encoding='utf-8') as file:
              file.write(hasil_transkrip)
          
          print(f"Transkripsi disimpan di {output_text}")

      if __name__ == "__main__":
          main()
    '';
  };

  propagatedBuildInputs = with pkgs.python3Packages; [
    speechrecognition
    pydub
  ];

  makeWrapperArgs = [ 
    "--prefix PATH : ${pkgs.ffmpeg}/bin"  # Untuk pydub
  ];

  meta = with pkgs.lib; {
    description = "Alat untuk mentranskrip file audio menjadi teks";
    homepage = "https://github.com/anda/audio2text";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
