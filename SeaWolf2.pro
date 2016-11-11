QT += quick bluetooth widgets

# allows to add DEPLOYMENTFOLDERS and links to the V-Play library and QtCreator auto-completion
#CONFIG += v-play

CONFIG+=qml_debug
qmlFolder.source = qml
DEPLOYMENTFOLDERS += qmlFolder # comment for publishing

assetsFolder.source = assets
DEPLOYMENTFOLDERS += assetsFolder
QML_IMPORT_PATH = .

# Add more folders to ship with the application here

#RESOURCES += #    resources.qrc # uncomment for publishing
#RESOURCES += resources.qrc # uncomment for publishing

# NOTE: for PUBLISHING, perform the following steps:
# 1. comment the DEPLOYMENTFOLDERS += qmlFolder line above, to avoid shipping your qml files with the application (instead they get compiled to the app binary)
# 2. uncomment the resources.qrc file inclusion and add any qml subfolders to the .qrc file; this compiles your qml files and js files to the app binary and protects your source code
# 3. change the setMainQmlFile() call in main.cpp to the one starting with "qrc:/" - this loads the qml files from the resources
# for more details see the "Deployment Guides" in the V-Play Documentation

# during development, use the qmlFolder deployment because you then get shorter compilation times (the qml files do not need to be compiled to the binary but are just copied)
# also, for quickest deployment on Desktop disable the "Shadow Build" option in Projects/Builds - you can then select "Run Without Deployment" from the Build menu in Qt Creator if you only changed QML files; this speeds up application start, because your app is not copied & re-compiled but just re-interpreted


# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    qmlfileaccess.cpp \
    deviceinfo.cpp \
    heartrate.cpp

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    OTHER_FILES += android/AndroidManifest.xml
}

ios {
    QMAKE_INFO_PLIST = ios/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST
}

# set application icons for win and macx
win32 {
    RC_FILE += win/app_icon.rc
}
macx {
    ICON = macx/app_icon.icns
}

DISTFILES += \
    TODO \
    README.md \
    README \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat \
    LICENSE \
    qml/common/draw.js \
    qml/config.json \
    android/res/values/strings.xml \
    assets/sounds/10sec.wav \
    assets/sounds/30sec.wav \
    assets/sounds/back.wav \
    assets/sounds/breathe.wav \
    assets/sounds/hold.wav \
    assets/sounds/walk.wav \
    android/res/drawable-hdpi/ic_launcher.png \
    android/res/drawable-hdpi/icon.png \
    android/res/drawable-ldpi/icon.png \
    android/res/drawable-mdpi/ic_launcher.png \
    android/res/drawable-mdpi/icon.png \
    android/res/drawable-xhdpi/ic_launcher.png \
    android/res/drawable-xxhdpi/ic_launcher.png \
    assets/img/blue_heart.png \
    assets/img/blue_heart_small.png \
    assets/img/busy_dark.png \
    assets/img/SeaWolf.png \
    assets/img/star.png \
    assets/img/surface.png \
    assets/img/vplay-logo.png \
    ios/Def-568h@2x.png \
    ios/Def-667h@2x.png \
    ios/Def-Portrait-736h@3x.png \
    ios/Def-Portrait.png \
    ios/Def-Portrait@2x.png \
    ios/Def.png \
    ios/Def@2x.png \
    ios/Icon-60.png \
    ios/Icon-60@2x.png \
    ios/Icon-60@3x.png \
    ios/Icon-72.png \
    ios/Icon-72@2x.png \
    ios/Icon-76.png \
    ios/Icon-76@2x.png \
    ios/Icon-Small-40.png \
    ios/Icon-Small-40@2x.png \
    ios/Icon-Small-50.png \
    ios/Icon-Small-50@2x.png \
    ios/Icon.png \
    ios/Icon@2x.png \
    win/app_icon.ico \
    assets/img/SeaWolf.xcf \
    assets/img/surface.xcf \
    win/app_icon.rc \
    android/gradle.properties \
    android/local.properties \
    qml/common/Button.qml \
    qml/common/SeaWolfFiles.qml \
    qml/common/MenuButton.qml \
    qml/common/SceneBase.qml \
    qml/common/SeaWolfButton.qml \
    qml/common/SeaWolfControls.qml \
    qml/scenes/AboutScene.qml \
    qml/scenes/ConfigPreferencesScene.qml \
    qml/scenes/ConfigSeriesScene.qml \
    qml/scenes/HrmSetupScene.qml \
    qml/scenes/RunSessionScene.qml \
    qml/Main.qml \
    qml/common/SeaWolfInput.qml \
    qml/scenes/BrowseResultsScene.qml \
    qml/common/SeaWolfPlot.qml

HEADERS += \
    qmlfileaccess.h \
    deviceinfo.h \
    heartrate.h \
    qmlelapsedtimer.h

RESOURCES += \
    resources.qrc
