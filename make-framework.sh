
function clean_all {
	rm -rf Siren_embed/DerivedData
	rm -rf src/ios/Siren_embed.xcframework
}

function build_frameworks {
	cd Siren_embed
	rm -rf DerivedData

	# device
	xcodebuild -quiet \
		-project Siren_embed.xcodeproj \
		-scheme Siren_embed \
		ONLY_ACTIVE_ARCH=NO \
		-destination="iOS" \
		-derivedDataPath "./DerivedData" \
		-sdk "iphoneos" \
		SKIP_INSTALL=NO \
		BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

	echo "iOS framework built"

	# simulator
	xcodebuild -quiet \
		-project Siren_embed.xcodeproj \
		-scheme Siren_embed \
		ONLY_ACTIVE_ARCH=NO \
		-destination="iOS Simulator" \
		-derivedDataPath "./DerivedData" \
		-sdk "iphonesimulator" \
		SKIP_INSTALL=NO \
		BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

	echo "iOS Simulator framework built"
	cd ..
}

function bundle_frameworks {
	local dest="src/ios/Siren_embed.xcframework"
	local src="Siren_embed/DerivedData/Build/Products"
	rm -r $dest

	xcodebuild -create-xcframework \
		-framework "$src/Debug-iphoneos/Siren_embed.framework" \
		-framework "$src/Debug-iphonesimulator/Siren_embed.framework" \
		-output $dest
}

if [ $# = 0 ]; then
	build_frameworks
	bundle_frameworks
else
	while [ $# -gt 0 ]; do
		case $1 in
			-clean)
				clean_all
				;;
			-build)
				build_frameworks
				;;
			-bundle)
				bundle_frameworks
				;;
		esac
		shift
	done
fi