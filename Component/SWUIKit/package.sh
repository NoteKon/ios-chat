# 打包framework脚本

echo "运行此脚本前，请先将Package-Project工程编译一遍，确保所有相关文件以已导入且正常运行，没有报错"
echo "======开始打包Framework======"

#工程名
PROJECT_NAME=SWUIKit
WORKSPACE_NAME=${PROJECT_NAME}.xcworkspace

#工程路径
PROJECT_DIR="Example/"

#build之后的文件夹路径
BUILD_DIR="Build/Products"

#打包模式 Debug/Release 默认是Release
development_mode=Debug

# 输出文件夹
UNIVERSAL_OUTPUTFOLDER="${PROJECT_NAME}/PackageFramework/"
INSTALL_DIR_A=${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.xcframework/ios-arm64/${PROJECT_NAME}.framework/${PROJECT_NAME}

# 清空输出文件夹
rm -drf "${UNIVERSAL_OUTPUTFOLDER}"
# 确保输出文件夹存在
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

echo "======Step 1. clean======"
cd ${PROJECT_DIR}
xcodebuild -workspace "${WORKSPACE_NAME}" -scheme "${PROJECT_NAME}" -configuration ${development_mode} clean
pod update --no-repo-update
cd ../
echo "======Step 2. build 真机版本======"
xcodebuild -workspace "${PROJECT_DIR}/${WORKSPACE_NAME}" -scheme "${PROJECT_NAME}" -configuration ${development_mode} -sdk iphoneos ONLY_ACTIVE_ARCH=YES -arch arm64 build
echo "======Step 3. build 模拟器版本(模拟器版本仅编译x86_64)======"
xcodebuild -workspace "${PROJECT_DIR}/${WORKSPACE_NAME}" -scheme "${PROJECT_NAME}" -configuration ${development_mode} -sdk iphonesimulator ONLY_ACTIVE_ARCH=YES -arch x86_64 build

# -f 判断文件是否存在
if [ -f "${PROJECT_DIR}/${BUILD_DIR}/${development_mode}-iphoneos/${PROJECT_NAME}/${PROJECT_NAME}.framework/${PROJECT_NAME}" ]
then
    echo "======生成xcframework"
    sh xcframework_maker/xcmaker.sh "${PROJECT_DIR}/${BUILD_DIR}/${development_mode}-iphonesimulator/${PROJECT_NAME}/${PROJECT_NAME}.framework" "${PROJECT_DIR}/${BUILD_DIR}/${development_mode}-iphoneos/${PROJECT_NAME}/${PROJECT_NAME}.framework" $UNIVERSAL_OUTPUTFOLDER $PROJECT_NAME
    echo "======生成xcframework结束======"

    # -f 判断文件是否存在
    if [ -f "${INSTALL_DIR_A}" ]
    then
        echo "======验证合成包是否成功======"
        lipo -info "${INSTALL_DIR_A}"
        echo "======清理编译文件======"
        rm -drf "${PROJECT_DIR}/${PROJECT_DIR}/Build"
        echo "======合成包成功,即将打开文件夹======"
        #打开目标文件夹
        open "${UNIVERSAL_OUTPUTFOLDER}"
    else
        echo "============================================================"
        echo "打包失败，请检查是否正确配置："
        echo "一、Example的podfile中的必须使用 ${PROJECT_NAME}/File 来install"
        echo "二、请检查Xcode的首选项是否正确配置："
        echo "1、在Xcode的菜单栏依次打开 Xcode -> Preferences... -> Locations"
        echo "2、Locations中，找到Derived Data，打开 Advanced..."
        echo "3、请选择 Custom 并设置为 Relative to Workspace, 并保存后重试。"
        echo "============================================================"
    fi
else
    echo "============================================================"
    echo "打包失败，请检查是否正确配置："
    echo "一、Example的podfile中的必须使用 ${PROJECT_NAME}/File 来install"
    echo "二、请检查Xcode的首选项是否正确配置："
    echo "1、在Xcode的菜单栏依次打开 Xcode -> Preferences... -> Locations"
    echo "2、Locations中，找到Derived Data，打开 Advanced..."
    echo "3、请选择 Custom 并设置为 Relative to Workspace, 并保存后重试。"
    echo "============================================================"
fi
