#!/bin/bash
#工程名
PROJECT_NAME=SWBusinessKit
# 基础组件仓库地址
COMPONENTS_PROJECT_PATH=Components/${PROJECT_NAME}/${PROJECT_NAME}/
# 业务组件仓库地址
MODULARS_PROJECT_PATH=Modulars/${PROJECT_NAME}/${PROJECT_NAME}/
# Framework仓库地址
FRAMEWORK_PROJECT_PATH=Frameworks/${PROJECT_NAME}/
FRAMEWORK_PACKAGE_PATH=${FRAMEWORK_PROJECT_PATH}/${PROJECT_NAME}/PackageFramework

#cd ../../
#
## 找到源码项目地址
#PROJECT_PATH=${COMPONENTS_PROJECT_PATH}
#if [ ! -d "${PROJECT_PATH}" ]
# then
#    PROJECT_PATH=${MODULARS_PROJECT_PATH}
#    if [ ! -d "${PROJECT_PATH}" ]
#     then
#        echo "请按指定路径创建工程文件！"
#        echo "源码库请放在 `Modulars（业务组件）`或`Components（基础组件）`文件夹下！"
#        exit
#    fi
#fi
#
#
#while true; do
#    stty -icanon min 0 time 100
#    echo -n "请确认源码仓库中的spec文件是否已修改完成：版本号、依赖等是否已设置为最新（y/n）？"
#    read Arg
#    case $Arg in
#    Y|y|YES|yes)
#      break;;
#    N|n|NO|no)
#      exit;;
#    "")
#      continue;;
#    esac
#done
#
## 判断是否已创建Framework工程
#if [ ! -d "${FRAMEWORK_PROJECT_PATH}" ]
# then
#    while true; do
#        stty -icanon min 0 time 100
#        echo -n "Framework仓库未创建，是否继续（y/n）？"
#        read Arg
#        case $Arg in
#        Y|y|YES|yes)
#          break;;
#        N|n|NO|no)
#          exit;;
#        "")
#          continue;;
#        esac
#    done
# else
#    while true; do
#        stty -icanon min 0 time 100
#        echo -n "请确认Framework仓库中的spec文件是否已修改完成：版本号、依赖等是否与源码工程一致（y/n）？"
#        read Arg
#        case $Arg in
#        Y|y|YES|yes)
#          break;;
#        N|n|NO|no)
#          exit;;
#        "")
#          continue;;
#        esac
#    done
#fi
#
#cd "${PROJECT_PATH}"
#
#echo "====== 执行打包脚本 ======"
#sh package.sh

## 打包结果
#PROJECT_PACKAGE_PATH="${PROJECT_PATH}/${PROJECT_NAME}.framework"
#if [ ! -f "${PROJECT_PACKAGE_PATH}" ]
# then
#    echo "==== 打包失败 ===="
#    exit
#fi
#
## -f 判断Framework项目是否存在
#if [ -f "${FRAMEWORK_PACKAGE_PATH}" ]
# then
#    echo "====== 复制Framework文件到Framework仓库"
#    cd "../../"
#    rm -drf "${FRAMEWORK_PACKAGE_PATH}/${PROJECT_NAME}.framework"
#    cp -R "${PROJECT_PACKAGE_PATH}" "${FRAMEWORK_PACKAGE_PATH}/"
#fi
#
#echo -n "打包完成，是否发版（y/n）？"
#while true; do
#    stty -icanon min 0 time 100
#    read shouldLint
#    case $shouldLint in
#    Y|y|YES|yes)
#      break;;
#    N|n|NO|no)
#      exit;;
#    "")
#      continue;;
#    esac
#done

#echo "====== 开始校验 ======"
#echo "====== 开始校验源码包 ======"
#cd "../../"
#cd "${PROJECT_PATH}"
#pod lib lint ${PROJECT_NAME}.podspec --sources=http://172.16.6.11:8050/Component/VVComponentSpec.git,https://github.com/CocoaPods/Specs.git --allow-warnings --skip-import-validation
#cd "../../"
#if [ -f "${FRAMEWORK_PROJECT_PATH}" ]
# then
#    echo "====== 开始校验Framework包 ======"
#    cd "${FRAMEWORK_PROJECT_PATH}"
#    pod lib lint ${PROJECT_NAME}.podspec --sources=http://172.16.6.11:8050/Component/VVComponentSpec.git,https://github.com/CocoaPods/Specs.git --allow-warnings --skip-import-validation
#fi
#
#echo -n "校验结束，请确认是否没有错误（y/n）？"
#while true; do
#    stty -icanon min 0 time 100
#    read shouldPush
#    case $shouldPush in
#    Y|y|YES|yes)
#      break;;
#    N|n|NO|no)
#      exit;;
#    "")
#      continue;;
#    esac
#done
    
#echo "====== 打包完成，开始打tag ======"
#echo -n "请输入要上传的版本号："
#read tag
#while [ "${tag}"="" ] do
#    echo -n "请输入要上传的版本号："
#    read tag
#done
#
#cd "${PROJECT_PATH}"
#git tag -a tag -m "自动打包版本 ${tag}"
#git push origin tag
#
#cd "../../"
#if [ -f "${FRAMEWORK_PROJECT_PATH}" ]
# then
#    cd "${FRAMEWORK_PROJECT_PATH}"
#    git tag -a tag -m "自动打包版本 ${tag}"
#    git push origin tag
#fi
#
#echo "====== 打tag完成，开始推送Spec ======"
#cd "../../"
#cd "${PROJECT_PATH}"
pod repo push http://172.16.6.11:8050/Component/VVComponentSpec.git ${PROJECT_NAME}.podspec --sources=http://172.16.6.11:8050/Component/VVComponentSpec.git,https://github.com/CocoaPods/Specs.git --allow-warnings --skip-import-validation
#cd "../../"
# if [ -f "${FRAMEWORK_PROJECT_PATH}" ]
#  then
#     cd "${FRAMEWORK_PROJECT_PATH}"
#     pod repo push http://172.16.6.11:8050/Frameworks/VVFrameworkSpec.git ${PROJECT_NAME}.podspec --sources=http://172.16.6.11:8050/Component/VVComponentSpec.git,https://github.com/CocoaPods/Specs.git --allow-warnings --skip-import-validation
# fi
# echo "====== 脚本执行完成，请验证是否已正确发版 ======"
