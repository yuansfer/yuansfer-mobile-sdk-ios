#!/bin/sh
set -e

BUILD_DIR=${SRCROOT}/build
PRODUCTS_DIR=~/Desktop/${PROJECT_NAME}"(build "$(date '+%Y-%m-%d %H_%M_%S')")"

xcodebuild -target ${PROJECT_NAME} -configuration Release -arch i386 -arch x86_64 -sdk iphonesimulator clean build
xcodebuild -target ${PROJECT_NAME} -configuration Release -arch armv7 -arch armv7s -arch arm64 build

if [ -d "${PRODUCTS_DIR}" ]
then
rm -rf "${PRODUCTS_DIR}"
fi

mkdir -p "${PRODUCTS_DIR}"

lipo -create -output "${PRODUCTS_DIR}/lib${PROJECT_NAME}.a" "${BUILD_DIR}/Release-iphoneos/lib${PROJECT_NAME}.a" "${BUILD_DIR}/Release-iphonesimulator/lib${PROJECT_NAME}.a"

cp "${BUILD_DIR}/Release-iphoneos/include/${PROJECT_NAME}/${PROJECT_NAME}.h" "${PRODUCTS_DIR}/${PROJECT_NAME}.h"

rm -R "${BUILD_DIR}"

open "${PRODUCTS_DIR}"
