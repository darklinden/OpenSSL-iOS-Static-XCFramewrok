#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
PROJECT_DIR="$(realpath "${BASEDIR}")"

echo "PROJECT_DIR: ${PROJECT_DIR}"

cd "$PROJECT_DIR" || exit

#Gerenare device framework
echo ""
echo "****************************************************************"
echo "*                 Generating device library                    *"
echo "****************************************************************"
rm -rf "${PROJECT_DIR}/build/OpenSSL-iphoneos.xcarchive"
xcodebuild archive -scheme "OpenSSL (iOS)" \
    -archivePath "${PROJECT_DIR}/build/OpenSSL-iphoneos.xcarchive" \
    -sdk iphoneos \
    -arch arm64 \
    SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

#Generate simulator framework
echo "****************************************************************"
echo "*                Generating simulator library                  *"
echo "****************************************************************"
rm -rf "${PROJECT_DIR}/build/OpenSSL-iossimulator.xcarchive"
xcodebuild archive -scheme "OpenSSL (iOS Simulator)" \
    -archivePath "${PROJECT_DIR}/build/OpenSSL-iossimulator.xcarchive" \
    -sdk iphonesimulator \
    BUILD_ACTIVE_ARCH=NO \
    SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

#Generate xcframework for both arches
echo "****************************************************************"
echo "*                 Generating xcframework                       *"
echo "****************************************************************"
rm -rf "${PROJECT_DIR}/build/OpenSSL.xcframework"
xcodebuild -create-xcframework \
    -library "${PROJECT_DIR}/build/OpenSSL-iphoneos.xcarchive/Products/Library/libOpenSSL.a" \
    -headers "${PROJECT_DIR}/build/OpenSSL-iphoneos.xcarchive/Products/Library/Headers" \
    -library "${PROJECT_DIR}/build/OpenSSL-iossimulator.xcarchive/Products/Library/libOpenSSL.a" \
    -headers "${PROJECT_DIR}/build/OpenSSL-iossimulator.xcarchive/Products/Library/Headers" \
    -output "${PROJECT_DIR}/build/OpenSSL.xcframework"
