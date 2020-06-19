// Qt
import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import Qt.labs.settings 1.0 as QLab
import QtQuick.Dialogs 1.3 as QQ1D
import Qaterial 1.0 as Qaterial
import QaterialEngine 1.0

Qaterial.ApplicationWindow
{
  id: window

  property string currentFilePath
  property string currentFileUrl
  property string currentFileName: currentFilePath.substring(currentFilePath.lastIndexOf('/')+1)

  property string errorString

  width: 1280
  height: 600
  visible: true
  title: `Qaterial Hot Reload - ${currentFilePath}`

  minimumHeight : 200
  minimumWidth : 200

  function loadFileInLoader(source)
  {
    Qaterial.DialogManager.close()
    loader.create(source)
  }

  function reload()
  {
    loadFileInLoader(currentFileUrl)
  }

  function loadFile(path)
  {
    Qaterial.DialogManager.close()
    QaterialEngine.unWatchFile(window.currentFilePath)
    currentFileUrl = path
    // remove prefixed "file:///"
    if(Qt.platform.os === "windows")
        path = path.replace(/^(file:\/{3})/,"");
    else
        path = path.replace(/^(file:\/{2})/,"");
    // unescape html codes like '%23' for '#'
    currentFilePath = decodeURIComponent(path);
    QaterialEngine.watchFile(window.currentFilePath)

    loader.create(window.currentFileUrl)
  }

  QLab.Settings
  {
      property alias width: window.width
      property alias height: window.height
      property alias x: window.x
      property alias y: window.y
      property alias currentFilePath: window.currentFilePath
      property alias currentFileUrl: window.currentFileUrl

      property alias formatHorizontalAlignCenter: formatHorizontalAlignCenter.checked
      property alias formatVerticalAlignCenter: formatVerticalAlignCenter.checked
      property alias formatHorizontalAlignLeft: formatHorizontalAlignLeft.checked
      property alias formatHorizontalAlignRight: formatHorizontalAlignRight.checked
      property alias formatVerticalAlignBottom: formatVerticalAlignBottom.checked
      property alias formatVerticalAlignTop: formatVerticalAlignTop.checked
      property alias fullScreen: fullScreen.checked
  }

  Shortcut
  {
      sequence: "F5"
      onActivated: () => window.reload()
  }

  Shortcut
  {
      sequence: "Ctrl+O"
      onActivated: () => fileDialog.open()
  }

  QQ1D.FileDialog
  {
      id: fileDialog
      title: "Please choose a file"
      onAccepted: () => window.loadFile(fileDialog.fileUrl.toString())
  }

  Connections
  {
    target: QaterialEngine
    onWatchedFileChanged: () => window.reload()
  }

  header: Qaterial.ToolBar
  {
    Row
    {
      Qaterial.AppBarButton
      {
        ToolTip.visible: hovered
        ToolTip.text: "Open File to Hot Reload"
        icon.source: Qaterial.Icons.folderOutline

        onClicked: () => fileDialog.open()
      }
      Qaterial.AppBarButton
      {
        ToolTip.visible: hovered
        ToolTip.text: "Reload (F5)"
        icon.source: Qaterial.Icons.sync

        onClicked: () => window.reload()
      }

      Qaterial.ToolSeparator {}

      Qaterial.ToolButton
      {
        id: formatHorizontalAlignCenter

        enabled: !fullScreen.checked && !formatHorizontalAlignLeft.checked && !formatHorizontalAlignRight.checked
        icon.source: Qaterial.Icons.formatHorizontalAlignCenter

        ToolTip.visible: hovered
        ToolTip.text: "Align Horizontal Center"

        onClicked: () => window.reload()
      }

      Qaterial.ToolButton
      {
        id: formatVerticalAlignCenter

        enabled: !fullScreen.checked && !formatVerticalAlignBottom.checked && !formatVerticalAlignTop.checked
        icon.source: Qaterial.Icons.formatVerticalAlignCenter

        ToolTip.visible: hovered
        ToolTip.text: "Align Vertical Center"

        onClicked: () => window.reload()
      }

      Qaterial.ToolSeparator {}

      Qaterial.ToolButton
      {
        id: formatHorizontalAlignLeft

        enabled: !fullScreen.checked && !formatHorizontalAlignCenter.checked
        icon.source: Qaterial.Icons.formatHorizontalAlignLeft

        ToolTip.visible: hovered
        ToolTip.text: "Align Left"

        onClicked: () => window.reload()
      }

      Qaterial.ToolButton
      {
        id: formatHorizontalAlignRight

        enabled: !fullScreen.checked && !formatHorizontalAlignCenter.checked
        icon.source: Qaterial.Icons.formatHorizontalAlignRight

        ToolTip.visible: hovered
        ToolTip.text: "Align Right"

        onClicked: () => window.reload()
      }

      Qaterial.ToolButton
      {
        id: formatVerticalAlignBottom

        enabled: !fullScreen.checked && !formatVerticalAlignCenter.checked
        icon.source: Qaterial.Icons.formatVerticalAlignBottom

        ToolTip.visible: hovered
        ToolTip.text: "Align Bottom"

        onClicked: () => window.reload()
      }

      Qaterial.ToolButton
      {
        id: formatVerticalAlignTop

        enabled: !fullScreen.checked && !formatVerticalAlignCenter.checked
        icon.source: Qaterial.Icons.formatVerticalAlignTop

        ToolTip.visible: hovered
        ToolTip.text: "Align Top"

        onClicked: () => window.reload()
      }

      Qaterial.ToolSeparator {}

      Qaterial.ToolButton
      {
        id: fullScreen

        enabled: !formatHorizontalAlignCenter.checked &&
                 !formatVerticalAlignCenter.checked &&
                 !formatHorizontalAlignLeft.checked &&
                 !formatHorizontalAlignRight.checked &&
                 !formatVerticalAlignBottom.checked &&
                 !formatVerticalAlignTop.checked
        icon.source: checked ? Qaterial.Icons.fullscreen : Qaterial.Icons.fullscreenExit

        ToolTip.visible: hovered
        ToolTip.text: checked ? "Fullscreen" : "Fullscreen Exit"

        onClicked: () => window.reload()
      }

    } // RowLayout
  } // ToolBar

  SplitView
  {
    anchors.fill: parent
    orientation: Qt.Vertical

    Item
    {
      id: loader
      width: parent.width
      SplitView.fillHeight: true
      property var loadedObject: null

      function create(url)
      {
        // Destroy previous item
        if(loadedObject)
        {
          loadedObject.destroy()
          loadedObject = null
        }

        QaterialEngine.clearCache()
        let component = Qt.createComponent(url)

        if (component.status === Component.Ready)
        {
          loadedObject = component.createObject(loader)

          if(fullScreen.checked)
            loadedObject.anchors.fill = loader
          if(formatHorizontalAlignCenter.checked)
            loadedObject.anchors.horizontalCenter = loader.horizontalCenter
          if(formatVerticalAlignCenter.checked)
            loadedObject.anchors.verticalCenter = loader.verticalCenter
          if(formatHorizontalAlignLeft.checked)
            loadedObject.anchors.left = loader.left
          if(formatHorizontalAlignRight.checked)
            loadedObject.anchors.right = loader.right
          if(formatVerticalAlignBottom.checked)
            loadedObject.anchors.bottom = loader.bottom
          if(formatVerticalAlignTop.checked)
            loadedObject.anchors.top = loader.top

          window.errorString = ""
        }
        else
        {
          window.errorString = component.errorString()
        }
      }

      Component.onCompleted: function()
      {
        if(window.currentFileUrl)
        {
          loader.create(window.currentFileUrl)
          QaterialEngine.watchFile(window.currentFilePath)
        }
      }

      Column
      {
        anchors.centerIn: parent
        spacing: 16
        visible: !window.currentFilePath
        Qaterial.Label
        {
          anchors.horizontalCenter: parent.horizontalCenter
          text: "Please Pick a qml file to get started"
        }
        Qaterial.RaisedButton
        {
          anchors.horizontalCenter: parent.horizontalCenter
          text: "Open File"
          icon.source: Qaterial.Icons.folderOutline

          onClicked: () => fileDialog.open()
        }
      }
    }

    StatusView
    {
      anchors.bottom: parent.bottom
      width: parent.width
      SplitView.minimumHeight: 40

      errorString: window.errorString
      file: window.currentFileName
    } // StatusView
  } // SplitView
} // ApplicationWindow