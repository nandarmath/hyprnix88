{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "speech-recognition";
  version = "3.14.0";
  pyproject = true;

  src = fetchPypi {
    pname = "speechrecognition";
    inherit version;
    hash = "sha256-jyPQElQi+sNYoFaXzv+11zh6P2mfwtz4Ke5pL7FUccI=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    audioop-lts
    standard-aifc
    typing-extensions
  ];

  optional-dependencies = with python3.pkgs; {
    assemblyai = [
      requests
    ];
    audio = [
      pyaudio
    ];
    dev = [
      numpy
      pytest
      pytest-randomly
      respx
    ];
    faster-whisper = [
      faster-whisper
    ];
    google-cloud = [
      google-cloud-speech
    ];
    groq = [
      groq
      httpx
    ];
    openai = [
      httpx
      openai
    ];
    pocketsphinx = [
      pocketsphinx
    ];
    whisper-local = [
      openai-whisper
      soundfile
    ];
  };

  pythonImportsCheck = [
    "speech_recognition"
  ];

  meta = {
    description = "Library for performing speech recognition, with support for several engines and APIs, online and offline";
    homepage = "https://pypi.org/project/SpeechRecognition/";
    license = with lib.licenses; [ gpl2Only bsd3 bsd2 ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "speech-recognition";
  };
}
