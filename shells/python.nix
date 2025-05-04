pkgs: {
  name = "Python";
  packages = [
    pkgs.python3
    (pkgs.python3.withPackages (
      p: with p; [
        pip
        autopep8
        pylint
        ipython
        poetry-core
        setuptools

        matplotlib
        numpy
        pandas
      ]
    ))
  ];

  shellHook = ''
    echo "## Python Development Shell ##"
    PYTHON_DIR="$XDG_DATA_HOME/python"
    export PYTHONSTARTUP="$PYTHON_DIR/pythonrc";
    export PIP_CONFIG_FILE="$PYTHON_DIR/pip/pip.conf";
    export PIP_LOG_FILE="$PYTHON_DIR/pip/log";
    export PYLINTHOME="$PYTHON_DIR/pylint";
    export PYLINTRC="$PYTHON_DIR/pylint/pylintrc";
    export IPYTHONDIR="$PYTHON_DIR/ipython";
  '';
}
