# BoxStarter install script for Craig's Surface Pro 3
#
# Open this URL in Internet Explorer on a freshly installed machine:
#
# http://boxstarter.org/package/url?https://raw.github.com/CraigJPerry/home-network/windows/surface.ps1
#

Update-ExecutionPolicy Unrestricted

Install-WindowsUpdate -AcceptEula
Enable-MicrosoftUpdate

Set-StartScreenOptions -EnableBootToDesktop 
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions
Set-TaskbarOptions -Dock Top

cinst Silverlight
cinst javaruntime

cinst Gow
cinst mingw
cinst sysinternals

cinst autohotkey
cinst ccleaner
cinst 7zip
cinst greenshot
cinst ant-renamer
cinst windirstat
cinst winmerge

cinst vim
cinst SublimeText3
cinst SublimeText3.PackageControl

cinst xming

cinst putty
cinst winscp

cinst fiddler4
cinst networkmonitor

cinst GoogleChrome
Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Google\Chrome\Application\chrome.exe"

cinst googledrive
cinst dropbox

cinst svn
cinst git

cinst java.jdk
cinst maven

cinst intellijidea-ultimate
Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\JetBrains\IntelliJ IDEA 13.1.5\bin\idea.exe"
cinst VisualStudioCommunity2013
cinst arduinoide

cinst python2
cinst easy.install

cinst nodejs
cinst npm

cinst virtualbox
cinst VirtualBox.ExtensionPack
cinst vagrant

cinst steam
cinst spotify
cinst handbrake
cinst vlc
cinst audacity

cinst deluge

easy_install pip
pip install pylint pep8 virtualenv

npm install -g gulp bower
