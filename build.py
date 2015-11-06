from pybuilder.core import init, use_plugin

use_plugin("python.core")
use_plugin("python.install_dependencies")
use_plugin("exec")

default_task = ["install_dependencies", "publish"]

@init
def initialize(project):
    project.set_property("dir_source_main_python", "ckan")
    project.depends_on_requirements("requirements.txt")
    project.set_property("publish_command", "sh install.sh")
