"""Build System - Control classes."""

import os
import random
import shutil
import yaml

class DirectoryError(Exception):
  """A problem with a directory."""
  pass

class NotADirectoryError(Exception):
  """A directory does not exist."""
  pass

class UnimplementedError(Exception):
  """A build rule isn't implemented by a Buildable subclass."""
  pass


def partition(pathname):
  """Split a pathname into directory and filename parts.

  Return dir_part, file_part.
  """
  if '/' in pathname:
    l = pathname.rindex('/')
    dir_part = pathname[0:l]
    file_part = pathname[l+1:]
    return dir_part, file_part

  return None, pathname

def copy_files(dest_dir, path_list):
  """Copy a list of files from their source directories into dest_dir."""

  for pathname in path_list:
    dir_part, file_part = partition(pathname)
    if dir_part:
      print(f'  Copy {pathname} into {dest_dir}/{file_part}')
      if not (os.path.exists(pathname) and os.path.isfile(pathname)):
        raise ValueError(f'Expected {pathname} to exist and it does not')

      shutil.copyfile(pathname, f'{dest_dir}/{file_part}')


class Buildable(object):
  """Superclass for artefact builders."""

  def __init__(self, name, source_dir, build_dir, artefact_dir, config):
    self.name = name
    self.source_dir = source_dir
    self.build_dir = build_dir
    self.artefact_dir = artefact_dir
    self.config = config

  def handle_depends(self):
    """Do any special action on the dependency list."""
    pass

class Assemble(Buildable):
  """Builds a .CMD file from a single .ASM file.

  Dependencies are expected to be already resolved, and available
  in self.build_dir.
  """

  def build(self):
    config = self.config

    # Do any special pre-build dependency handling
    self.handle_depends()

    build_dir = self.build_dir + '/' + self.source_dir
    filename = self.config['assemble']
    cmd = f'zmac -I {build_dir} -DMODEL1 -L --mras --od {build_dir} --oo cmd,lst {build_dir}/{filename}'
    rc = os.system(cmd)
    if rc != 0:
      print(f'system({cmd}) failed, code {rc}')
      return False
    else:
      print(f'system({cmd}) succeeded')
      return True

  def handle_depends(self):
    """Copy all dependencies into the current directory."""
    d = self.config['depends']
    build_dir = self.build_dir + '/' + self.source_dir
    copy_files(dest_dir=build_dir, path_list = d)

class Library(Buildable):
  """Builds a .lib file."""

  def build(self):
    config = self.config

    build_dir = self.build_dir + '/' + self.source_dir
    filename = self.config['library']
    dependencies = ' '.join(build_dir + '/' + x for x in self.config['depends'])
    print(f'  Library dependencies: {dependencies}')
    cmd = f'sdar r {build_dir}/{filename} {dependencies}'
    rc = os.system(cmd)
    if rc != 0:
      print(f'system({cmd}) failed, code {rc}')
      return False
    else:
      print(f'system({cmd}) succeeded')
      return True


class LinkSDCC(Buildable):
  """Links a .cmd file from libraries and .rel files."""

  def build(self):
    config = self.config

    build_dir = self.build_dir + '/' + self.source_dir
    filename = self.config['link']

    z80libdir = '-L ~/sdcc/share/sdcc/lib/z80'
    extralibdir = ''
    crt0='--no-std-crt0 library/sdcc/crt0.rel'

    depend_libs = []
    for x in self.config['depends']:
      if '.lib' in x:
        if '/' in x:
          depend_libs.append(f'{self.build_dir}/{x}')
        else:
          depend_libs.append(f'{self.build_dir}/{self.source_dir}/{x}')

    print(f'depend_libs is {depend_libs}')
    libs = ' '.join(f'-l {x}' for x in depend_libs)
    depend_rels = [x for x in self.config['depends'] if '.rel' in x]
    rels = ' '.join(f'{build_dir}/{x}' for x in depend_rels)
    print(f'rels is {rels}')

    # Step 1, built filename.ihx
    cmd = f'sdcc -mz80 --code-loc 0x5200 -o {build_dir}/{filename}.ihx {z80libdir} {extralibdir} {crt0} {libs} {rels}'
    rc = os.system(cmd)
    if rc != 0:
      print(f'system({cmd}) failed, code {rc}')
      return False
    else:
      print(f'system({cmd}) succeeded')

    dest_path = f'{build_dir}/{filename}.ihx'
    if not os.path.exists(dest_path):
      print(f'Path {dest_path} does not exist - failing')
      return False

    cmd = f"sed -e 's/:00000001FF/:00520001AD/' < {build_dir}/{filename}.ihx | bin/hex2cmd.py --output {build_dir}/{filename}.cmd"
    rc = os.system(cmd)
    if rc != 0:
      print(f'system({cmd}) failed, code {rc}')
      return False
    else:
      print(f'system({cmd}) succeeded')

    return True

class SDCC(Buildable):
  """Builds a .rel file from a .c file."""

  def build(self):
    config = self.config

    build_dir = self.build_dir + '/' + self.source_dir
    filename = self.config['sdcc']
    cmd = f'sdcc -mz80 -o {build_dir}/ -Iinclude/sdcc -c {build_dir}/{filename}'
    rc = os.system(cmd)
    if rc != 0:
      print(f'system({cmd}) failed, code {rc}')
      return False
    else:
      print(f'system({cmd}) succeeded')
      return True


class BuildSystem(object):
  def __init__(self, build_dir):
    self.build_dir = build_dir
    self.is_built = set()

    if not os.path.exists(build_dir):
      os.mkdir(build_dir)
    elif not os.path.isdir(build_dir):
      raise NotADirectoryError(f'{build_dir} is not a directory')
    else:
      print(f'Warning: {build_dir} exists')

  def build_sequence(self, directory):
    """Build contents of 'directory' and call self recursively for dependent directories."""

    print(f'Testing {directory}')
    if directory in self.is_built:
      print(f'Already built: {directory}')
      return

    db = DirectoryBuilder(source_dir=directory, artefact_dir='artefacts', build_dir=self.build_dir)
    needed_dirs = db.dependency_dirs()
    if needed_dirs:
      print(f'{directory} needs these dirs built first:', repr(needed_dirs))
      for d in needed_dirs:
        self.build_sequence(d)
      print(f'Recursion done; will now build {directory}')

    # Build here
    print(f'Building: {directory}')
    db.build_all()
    self.is_built.add(directory)


class DirectoryBuilder(object):
  """A DirectoryBuilder can build the artefacts defined for a single directory."""

  def __init__(self, source_dir, artefact_dir, build_dir):
    if not os.path.isdir(source_dir):
      raise NotADirectoryError(f'{source_dir} is not a directory')

    if not os.path.isdir(artefact_dir):
      raise NotADirectoryError(f'{artefact_dir} is not a directory')

    self.source_dir = source_dir
    self.artefact_dir = artefact_dir
    self.build_dir = build_dir
    self.config = None

    # Each built artefact is added to the set
    self.is_built = set()

    control_file = source_dir + '/BUILD.yaml'
    if os.path.isfile(control_file):
      with open(control_file, "r") as f:
        self.config = yaml.safe_load(f)

    # Fix config to edit out directory self-references from depends
    if not self.config:
      return

    fix_count = 0

    for f in self.config:
      c = self.config[f]
      if 'depends' in c:
        d = c['depends']
        new_depends = list()
        for pathname in d:
          dir_part, file_part = partition(pathname)
          if dir_part and dir_part == self.source_dir:
            new_depends.append(file_part)
            fix_count = fix_count + 1
          else:
            new_depends.append(pathname)
        c['depends'] = new_depends


    if fix_count > 0:
      print(f'Fixed {fix_count} directory self-references in {self.source_dir}')

  def artefact_path(self, filename):
    """Return pathname of filename in artefact_dir."""
    return self.artefact_dir + '/' + filename

  def built_path(self, filename):
    """Return pathname of filename in build_dir."""
    return f'{self.build_dir}/{self.source_dir}/{filename}'

  def source_path(self, filename):
    """Return pathname of filename in source_dir."""
    return self.source_dir + '/' + filename

  def dependency_dirs(self):
    """Return a set of the directories which must be built first."""
    if not self.config:
      return set()

    needed_dirs = set()
    for f in self.config:
      c = self.config[f]
      if 'depends' in c:
        dependencies = c['depends']
        for df in dependencies:
          # df is either a filename (aaa.bbb) or a pathname (d/d/d/aaa.bbb)
          # If the latter, return d/d/d
          if '/' in df:
            l = df.rindex('/')
            needed_dirs.add(df[0:l])

    return needed_dirs

  def build_all(self):
    """Build all artefacts in this directory.

    Calls build_sequence(f) on each artefact.
    """
    if not self.config:
      # No BUILD.yaml file; there is nothing to do
      return

    for filename in self.config:
      self.build_sequence(filename, level=0)
      print(f'Later: copy {self.build_dir}/{self.source_dir}/{filename} to {self.artefact_dir}')

  def build_sequence(self, filename, level=0):
    """Build filename in this directory and call self recursively for dependencies."""
    prefix = ' ' * (level * 2)
    print(f'{prefix}Test {filename} in {self.source_dir}')

    if filename in self.is_built:
      print(f'{prefix}Already built: {filename} (ignoring)')
      # return

    # Dependencies in other directories have to be built already
    if '/' in filename:
      pathname = self.build_dir + '/' + filename
      if not os.path.isfile(pathname):
        # raise ValueError(f'Expected {filename} to be built already in {pathname}')
        print(f'Warning: {filename} not built in {pathname}')
      else:
        print(f'{prefix}Remote already built: {pathname}')
      self.is_built.add(filename)
      return

    pathname = self.built_path(filename)
    if os.path.exists(pathname):
      print(f'{prefix}Already exists: {pathname}')
      return
    print(f'{prefix}Does not exist: {pathname}')

    # FIXME: Assumes that self.source_dir is relative
    built_dir = self.build_dir + '/' + self.source_dir

    pathname = self.source_path(filename)
    if os.path.exists(pathname):
      print(f'{prefix}Already exists: {pathname}')
      if not os.path.exists(built_dir):
        print(f'{prefix}Making directory: {built_dir}')
        os.makedirs(built_dir)
      elif not os.path.isdir(built_dir):
        raise ValueError(f'{built_dir} exists, but it is not a directory')

      # Copy the file into the built_dir
      shutil.copyfile(pathname, built_dir + '/' + filename)
      print(f'{prefix}  Copied {pathname} into {built_dir}')
      return
    print(f'{prefix}Does not exist: {pathname}')

    # Build it from the config

    if filename not in self.config:
      raise ValueError(f'{self.source_dir} needs {filename} but it does not exist and has no build rule')

    d = self.config[filename]
    if 'skip' in d:
      print(f'{filename} skipped due to {d["skip"]}')
      return False

    if 'depends' not in d:
      print(f'{filename} has no dependencies; nothing to build')
      return True

    depends = self.config[filename]['depends']
    for f in depends:
      self.build_sequence(f, level + 1)

    if 'copy' in self.config[filename]:
      c = self.config[filename]['copy']
      copy_files(built_dir, c)

    # Dependencies now available; build it in this directory
    file_config = self.config[filename]
    cls = None
    if 'sdcc' in file_config:
      cls = SDCC
    elif 'assemble' in file_config:
      cls = Assemble
    elif 'library' in file_config:
      cls = Library
    elif 'link' in file_config:
      cls = LinkSDCC

    buildable = None
    if cls:
      buildable = cls(filename, self.source_dir, self.build_dir, self.artefact_dir, file_config)

    if not buildable:
      raise UnimplementedError(f'No logic to build {filename} in {self.source_dir}')

    ok = buildable.build()
    if not ok:
      print(f'{prefix}FAILURE building {filename} in {self.source_dir}')
      raise ValueError(f'Build failed: {filename} in {self.build_dir}/{self.source_dir}')
    self.is_built.add(filename)
    print(f'{prefix}SUCCESS building {filename} in {self.source_dir}')
    return
