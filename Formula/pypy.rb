class Pypy < Formula
  desc "Highly performant implementation of Python 2 in Python"
  homepage "https://pypy.org/"
  url "https://bitbucket.org/pypy/pypy/downloads/pypy2.7-v7.3.1-src.tar.bz2"
  sha256 "fa3771514c8a354969be9bd3b26d65a489c30e28f91d350e4ad2f4081a9c9321"
  head "https://foss.heptapod.net/pypy/pypy", :using => :hg

  bottle do
    cellar :any
    sha256 "8fe21e711869c62e75b783a98f7c3228439598eb7fc53748ff10728a0a6995e5" => :catalina
    sha256 "450d0146d1a3c7c96eeb51c723d1697b873f1cf84dbc0166f88df23146478352" => :mojave
    sha256 "ecef513881fc2671911e60c0f0b9a54eab821808c08254f452ad69320884e88a" => :high_sierra
    sha256 "d22ce3e873a00cf63ad483d64b80dcaf23d5908108fff7a5774147336f35d56b" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on :arch => :x86_64
  depends_on "gdbm"
  # pypy does not find system libffi, and its location cannot be given
  # as a build option
  depends_on "libffi" if OS.mac? && DevelopmentTools.clang_build_version >= 1000
  depends_on "openssl@1.1"
  depends_on "sqlite"
  depends_on "tcl-tk"

  uses_from_macos "expat"
  uses_from_macos "libffi"
  uses_from_macos "unzip"
  uses_from_macos "zlib"

  resource "bootstrap" do
    if OS.mac?
      url "https://bitbucket.org/pypy/pypy/downloads/pypy2.7-v7.3.0-osx64.tar.bz2"
      sha256 "ca7b056b243a6221ad04fa7fc8696e36a2fb858396999dcaa31dbbae53c54474"
    else
      url "https://bitbucket.org/pypy/pypy/downloads/pypy2.7-v7.3.0-linux64.tar.bz2"
      sha256 "f4950a54378ac637da2a6defa52d6ffed96af12fcd5d74e1182fb834883c9826"
    end
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/b5/96/af1686ea8c1e503f4a81223d4a3410e7587fd52df03083de24161d0df7d4/setuptools-46.1.3.zip"
    sha256 "795e0475ba6cd7fa082b1ee6e90d552209995627a2a227a47c6ea93282f4bfb1"
  end

  resource "pip" do
    url "https://files.pythonhosted.org/packages/8e/76/66066b7bc71817238924c7e4b448abdb17eb0c92d645769c223f9ace478f/pip-20.0.2.tar.gz"
    sha256 "7db0c8ea4c7ea51c8049640e8e6e7fde949de672bfa4949920675563a5a6967f"
  end

  def install
    if OS.mac?
      ENV.prepend_path "PKG_CONFIG_PATH", "#{prefix}/opt/tcl-tk/lib/pkgconfig"
      ENV.prepend "LDFLAGS", "-L#{prefix}/opt/tcl-tk/lib"
      ENV.prepend "CPPFLAGS", "-I#{prefix}/opt/tcl-tk/include"
    end
    # Having PYTHONPATH set can cause the build to fail if another
    # Python is present, e.g. a Homebrew-provided Python 2.x
    # See https://github.com/Homebrew/homebrew/issues/24364
    ENV["PYTHONPATH"] = ""
    ENV["PYPY_USESSION_DIR"] = buildpath

    # Fix build on High Sierra
    inreplace "lib_pypy/_tkinter/tklib_build.py" do |s|
      if OS.mac?
        s.gsub! "/System/Library/Frameworks/Tk.framework/Versions/Current/Headers/",
                "#{prefix}/opt/tcl-tk/include"
        s.gsub! "libdirs = []",
                "libdirs = ['#{prefix}/opt/tcl-tk/lib']"
      else
        s.gsub! "/usr/include/tcl", Formula["tcl-tk"].opt_include.to_s
        s.gsub! "'tcl' + _ver, 'tk' + _ver", "'tcl8.6', 'tk8.6'"
      end
    end

    resource("bootstrap").stage buildpath/"bootstrap"
    python = buildpath/"bootstrap/bin/pypy"

    cd "pypy/goal" do
      system python, buildpath/"rpython/bin/rpython",
             "-Ojit", "--shared", "--cc", ENV.cc,
             "--make-jobs", ENV.make_jobs, "targetpypystandalone.py"
    end

    libexec.mkpath
    cd "pypy/tool/release" do
      package_args = %w[--archive-name pypy --targetdir .]
      system python, "package.py", *package_args
      system "tar", "-C", libexec.to_s, "--strip-components", "1", "-xf", "pypy.tar.bz2"
    end

    dylib = OS.mac? ? "dylib" : "so"
    (libexec/"lib").install libexec/"bin/libpypy-c.#{dylib}"
    if OS.mac?
      MachO::Tools.change_install_name("#{libexec}/bin/pypy",
                                       "@rpath/libpypy-c.dylib",
                                       "#{libexec}/lib/libpypy-c.dylib")
    end

    # The PyPy binary install instructions suggest installing somewhere
    # (like /opt) and symlinking in binaries as needed. Specifically,
    # we want to avoid putting PyPy's Python.h somewhere that configure
    # scripts will find it.
    bin.install_symlink libexec/"bin/pypy"
    lib.install_symlink libexec/"lib/libpypy-c.#{dylib}"

    # Delete two files shipped which we do not want to deliver
    # These files make patchelf fail
    unless OS.mac?
      rm_f libexec/"bin/libpypy-c.so.debug"
      rm_f libexec/"bin/pypy.debug"
    end
  end

  def post_install
    # Post-install, fix up the site-packages and install-scripts folders
    # so that user-installed Python software survives minor updates, such
    # as going from 1.7.0 to 1.7.1.

    # Create a site-packages in the prefix.
    prefix_site_packages.mkpath

    # Symlink the prefix site-packages into the cellar.
    unless (libexec/"site-packages").symlink?
      # fix the case where libexec/site-packages/site-packages was installed
      rm_rf libexec/"site-packages/site-packages"
      mv Dir[libexec/"site-packages/*"], prefix_site_packages
      rm_rf libexec/"site-packages"
    end
    libexec.install_symlink prefix_site_packages

    # Tell distutils-based installers where to put scripts
    scripts_folder.mkpath
    (distutils+"distutils.cfg").atomic_write <<~EOS
      [install]
      install-scripts=#{scripts_folder}
    EOS

    %w[setuptools pip].each do |pkg|
      resource(pkg).stage do
        system bin/"pypy", "-s", "setup.py", "--no-user-cfg", "install",
               "--force"
      end
    end

    # Symlinks to easy_install_pypy and pip_pypy
    bin.install_symlink scripts_folder/"easy_install" => "easy_install_pypy"
    bin.install_symlink scripts_folder/"pip" => "pip_pypy"

    # post_install happens after linking
    %w[easy_install_pypy pip_pypy].each { |e| (HOMEBREW_PREFIX/"bin").install_symlink bin/e }
  end

  def caveats
    <<~EOS
      A "distutils.cfg" has been written to:
        #{distutils}
      specifying the install-scripts folder as:
        #{scripts_folder}

      If you install Python packages via "pypy setup.py install", easy_install_pypy,
      or pip_pypy, any provided scripts will go into the install-scripts folder
      above, so you may want to add it to your PATH *after* #{HOMEBREW_PREFIX}/bin
      so you don't overwrite tools from CPython.

      Setuptools and pip have been installed, so you can use easy_install_pypy and
      pip_pypy.
      To update setuptools and pip between pypy releases, run:
          pip_pypy install --upgrade pip setuptools

      See: https://docs.brew.sh/Homebrew-and-Python
    EOS
  end

  # The HOMEBREW_PREFIX location of site-packages
  def prefix_site_packages
    HOMEBREW_PREFIX+"lib/pypy/site-packages"
  end

  # Where setuptools will install executable scripts
  def scripts_folder
    HOMEBREW_PREFIX+"share/pypy"
  end

  # The Cellar location of distutils
  def distutils
    libexec+"lib-python/2.7/distutils"
  end

  test do
    system bin/"pypy", "-c", "print('Hello, world!')"
    system bin/"pypy", "-c", "import time; time.clock()"
    system scripts_folder/"pip", "list"
  end
end
