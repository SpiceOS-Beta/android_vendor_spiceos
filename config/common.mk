# Allow vendor/extra to override any property by setting it first
$(call inherit-product-if-exists, vendor/extra/product.mk)

PRODUCT_BRAND ?= SpiceOS

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

ifeq ($(TARGET_BUILD_VARIANT),eng)
# Disable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=0
else
# Enable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=1

# Disable extra StrictMode features on all non-engineering builds
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.strictmode.disable=true
endif

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/spiceos/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/spiceos/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/spiceos/prebuilt/common/bin/50-lineage.sh:$(TARGET_COPY_OUT_SYSTEM)/addon.d/50-lineage.sh

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/addon.d/50-lineage.sh

ifneq ($(strip $(AB_OTA_PARTITIONS) $(AB_OTA_POSTINSTALL_CONFIG)),)
PRODUCT_COPY_FILES += \
    vendor/spiceos/prebuilt/common/bin/backuptool_ab.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.sh \
    vendor/spiceos/prebuilt/common/bin/backuptool_ab.functions:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.functions \
    vendor/spiceos/prebuilt/common/bin/backuptool_postinstall.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_postinstall.sh

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/backuptool_ab.sh \
    system/bin/backuptool_ab.functions \
    system/bin/backuptool_postinstall.sh

ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.ota.allow_downgrade=true
endif
endif

# Lineage-specific broadcast actions whitelist
PRODUCT_COPY_FILES += \
    vendor/spiceos/config/permissions/lineage-sysconfig.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/lineage-sysconfig.xml

# Lineage-specific init rc file
PRODUCT_COPY_FILES += \
    vendor/spiceos/prebuilt/common/etc/init/init.lineage-system.rc:$(TARGET_COPY_OUT_PRODUCT)/etc/init/init.lineage-system.rc

# Enable Android Beam on all targets
PRODUCT_COPY_FILES += \
    vendor/spiceos/config/permissions/android.software.nfc.beam.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.nfc.beam.xml

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_PRODUCT)/usr/keylayout/Vendor_045e_Product_0719.kl

# This is Lineage!
PRODUCT_COPY_FILES += \
    vendor/spiceos/config/permissions/org.lineageos.android.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/org.lineageos.android.xml

# Enforce privapp-permissions whitelist
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.control_privapp_permissions=enforce

# Include AOSP audio files
include vendor/spiceos/config/aosp_audio.mk

# Include Lineage audio files
include vendor/spiceos/config/lineage_audio.mk

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Disable vendor restrictions
PRODUCT_RESTRICT_VENDOR_FILES := false

# Bootanimation
TARGET_SCREEN_WIDTH ?= 1080
TARGET_SCREEN_HEIGHT ?= 1920
PRODUCT_PACKAGES += \
    bootanimation.zip

# Lineage packages
PRODUCT_PACKAGES += \
    LineageParts \
    LineageSettingsProvider \
    LineageSetupWizard \
    Updater

PRODUCT_COPY_FILES += \
    vendor/spiceos/prebuilt/common/etc/init/init.lineage-updater.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.lineage-updater.rc

# Themes
PRODUCT_PACKAGES += \
    LineageThemesStub \
    ThemePicker

# Config
PRODUCT_PACKAGES += \
    SimpleDeviceConfig

# Extra tools in Lineage
PRODUCT_PACKAGES += \
    7z \
    bash \
    curl \
    getcap \
    htop \
    lib7z \
    nano \
    pigz \
    setcap \
    unrar \
    vim \
    zip

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/curl \
    system/bin/getcap \
    system/bin/setcap

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

PRODUCT_COPY_FILES += \
    vendor/spiceos/prebuilt/common/etc/init/init.openssh.rc:$(TARGET_COPY_OUT_PRODUCT)/etc/init/init.openssh.rc

# rsync
PRODUCT_PACKAGES += \
    rsync

# ThemeOverlays
include vendor/overlays/themes.mk

# Storage manager
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.storage_manager.enabled=true

# These packages are excluded from user builds
PRODUCT_PACKAGES_DEBUG += \
    procmem

ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/procmem
endif

# Root
PRODUCT_PACKAGES += \
    adb_root
ifneq ($(TARGET_BUILD_VARIANT),user)
ifeq ($(WITH_SU),true)
PRODUCT_PACKAGES += \
    su
endif
endif

# Face Unlock
TARGET_FACE_UNLOCK_SUPPORTED ?= true
ifeq ($(TARGET_FACE_UNLOCK_SUPPORTED),true)
PRODUCT_PACKAGES += \
    FaceUnlockService
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.face_unlock_service.enabled=$(TARGET_FACE_UNLOCK_SUPPORTED)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.biometrics.face.xml
endif

# Dex preopt
PRODUCT_DEXPREOPT_SPEED_APPS += \
    SystemUI

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/spiceos/overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/spiceos/overlay/common

PRODUCT_VERSION_MAJOR = 5
PRODUCT_VERSION_MINOR = 5

SPICEOS_BUILDTYPE ?= UNOFFICIAL
SPICEOS_EDITION := STABLE

SPICEOS_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(SPICEOS_EDITION)-$(shell date +%Y%m%d-%H%M%S)-$(SPICEOS_BUILD)-$(SPICEOS_BUILDTYPE)
SPICEOS_DISPLAY_VERSION := SpiceOS-$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(SPICEOS_EDITION)-$(SPICEOS_BUILD)-$(SPICEOS_BUILDTYPE)

PRODUCT_EXTRA_RECOVERY_KEYS += \
    vendor/spiceos/build/target/product/security/lineage

-include vendor/lineage-priv/keys/keys.mk

SPICEOS_DISPLAY_VERSION := $(SPICEOS_VERSION)

ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),)
ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),build/target/product/security/testkey)
    ifneq ($(SPICEOS_BUILDTYPE), UNOFFICIAL)
        ifndef TARGET_VENDOR_RELEASE_BUILD_ID
            ifneq ($(SPICEOS_EXTRAVERSION),)
                # Remove leading dash from SPICEOS_EXTRAVERSION
                SPICEOS_EXTRAVERSION := $(shell echo $(SPICEOS_EXTRAVERSION) | sed 's/-//')
                TARGET_VENDOR_RELEASE_BUILD_ID := $(SPICEOS_EXTRAVERSION)
            else
                TARGET_VENDOR_RELEASE_BUILD_ID := $(shell date -u +%Y%m%d)
            endif
        else
            TARGET_VENDOR_RELEASE_BUILD_ID := $(TARGET_VENDOR_RELEASE_BUILD_ID)
        endif
        ifeq ($(SPICEOS_VERSION_MAINTENANCE),0)
            SPICEOS_DISPLAY_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(SPICEOS_BUILD)
        else
            SPICEOS_DISPLAY_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(SPICEOS_VERSION_MAINTENANCE)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(SPICEOS_BUILD)
        endif
    endif
endif
endif

-include $(WORKSPACE)/build_env/image-auto-bits.mk
-include vendor/spiceos/config/partner_gms.mk
