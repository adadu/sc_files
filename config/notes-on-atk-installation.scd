/*
When installing ATK, there seem to be compoents in both the sc3plugins and in the Quarks. Ensure that you include paths for interpreter to location of
/Extensions/sc3-plugins/ which is either root level or user level. SC3 automatically looks at user folder for extensions, not at root, but it still needs a path to the sc3-plugins folder. Then Run commands for ATK Kernal, Matrix and Sounds Installation - which only creates a folder and opens it. Place unzipped files in there.
*/

/*
LINUX - download source matrices and kernel files, rename unzipped folders to match those names, run Atk.creatUserSupportDir cmd, open folder, move folders to this location

*/

Quarks.install("https://github.com/ambisonictoolkit/atk-sc3.git");

Quarks.gui

(
// post the directory in which to move the SC3Plugins folder
Platform.userExtensionDir.postln;
)
(
// alternatively, SC can open it for you
// (assuming it already exists! - you may need to create /Extensions)
Platform.userExtensionDir.openOS;
)

//ATK Kernel Installation
(
// Create ATK support directory
// Place unzipped kernels in the directory opened

Atk.createUserSupportDir;
Atk.openUserSupportDir;
)

//ATK Matrix Installation
(
// Create ATK support directory
// Place unzipped matrices in the directory opened

Atk.createUserSupportDir;
Atk.openUserSupportDir;
)

//Sounds Installation
(
// Place unzipped kernels in the directory opened
// Presume Atk.userSupportDir has already been created
Atk.openUserSupportDir;
)

