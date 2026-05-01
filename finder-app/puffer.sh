mon code est il ok? #!/bin/bash
# ==============================================================================
# Script d'installation et de compilation du noyau Linux ARM64 + rootfs/BusyBox
# Auteur original : Siddhant Jajoo
# Modifications/Adaptations : Arnaud (18DEC2025)
# Objectif : Compiler un noyau Linux pour QEMU ARM64 et préparer un rootfs fonctionnel
# ==============================================================================

# ------------------------------------------------------------------------------
# CONFIGURATION GLOBALE (adaptée à l'environnement de l'utilisateur)
# ------------------------------------------------------------------------------
set -e  # Arrêter le script en cas d'erreur
set -u  # Arrêter le script si une variable non définie est utilisée

#set -x

# Chemins principaux (ABSOLUS pour éviter les erreurs de chemin relatif)
OUTDIR=/home/tchuinkou/aeld          # Dossier de sortie principal
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163             # Version du noyau Linux
BUSYBOX_VERSION=1_33_1               # Version de BusyBox
FINDER_APP_DIR=$(realpath $(dirname $0))  # Dossier du script finder-app
ARCH=arm64                           # Architecture cible
CROSS_COMPILE=aarch64-none-linux-gnu- # Cross-compilateur ARM64

# Variables spécifiques au rootfs (dossiers critiques)
DEV_DIR="${OUTDIR}/rootfs/dev"       # Dossier /dev du rootfs (périphériques)
ROOTFS_BIN="${OUTDIR}/rootfs/bin"    # Dossier /bin du rootfs (binaires BusyBox)
WRITER_DIR="/home/tchuinkou/aesd-assignments/finder-app"  # Dossier du writer.c/Makefile

read -p "Appuie sur Entrée pour continuer..."
echo "		"


# ------------------------------------------------------------------------------
echo "GESTION DU DOSSIER DE SORTIE (OUTDIR)"
# ------------------------------------------------------------------------------
if [ $# -lt 1 ]; then
    echo "[1/17] Utilisation du dossier par défaut : ${OUTDIR}"
else
    OUTDIR=$1
    echo "[1/17] Utilisation du dossier passé en argument : ${OUTDIR}"
fi

# Créer le dossier de sortie si il n'existe pas
mkdir -p ${OUTDIR}

read -p "Appuie sur Entrée pour continuer..."
echo "					"

# ------------------------------------------------------------------------------
echo "ÉTAPE 1 : CLONAGE DU DÉPÔT LINUX-STABLE (si non présent) "
# ------------------------------------------------------------------------------
cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    echo "[2/17] CLONAGE DU DÉPÔT LINUX STABLE (version ${KERNEL_VERSION})"
    git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi

read -p "Appuie sur Entrée pour continuer..."
echo "					"

# ------------------------------------------------------------------------------
echo "ÉTAPE 2 : COMPILATION DU NOYAU LINUX ARM64"
# ------------------------------------------------------------------------------
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    pwd
    echo "[3/17] Checkout de la version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # Sous-étape 2.1 : Nettoyage des anciennes compilations (conserve la config .config)
    # ⚠️ Attention : make distclean SUPPRIME la config → utiliser make clean ici
    echo -e "\n[2.1/17] Nettoyage des anciennes compilations..."
    make ARCH=${ARCH} clean -j$(nproc)

    # Sous-étape 2.2 : Génération d'une configuration par défaut (QEMU ARM64)
    echo -e "\n[2.2/17] Génération de la configuration par défaut (defconfig)..."
    make ARCH=${ARCH} defconfig -j$(nproc)

    # Sous-étape 2.3 : Configuration graphique du noyau (menuconfig)
    echo -e "\n[2.3/17] Ouverture de menuconfig (configuration graphique)..."
    read -p "Appuyez sur ENTER pour ouvrir menuconfig (sauvegardez la config avant de quitter)..."
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} menuconfig

    # Sous-étape 2.4 : Validation de la configuration (évite les questions pendant la compilation)
    echo -e "\n[2.4/17] Validation de la configuration (oldconfig)..."
    yes "" | make ARCH=${ARCH} oldconfig -j$(nproc)

    # Sous-étape 2.5 : Compilation du noyau (Image ARM64)
    echo -e "\n[2.5/17] Compilation du noyau Image (ARM64)..."
    make -j$(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} Image
    
    # Vérification : Le fichier Image doit exister
    if [ ! -f "arch/${ARCH}/boot/Image" ]; then
        echo "ERREUR : Fichier Image non généré !"
        read -p "Appuie sur Entrée pour continuer..."
        exit 1
    fi

    # Sous-étape 2.6 : Compilation des modules du noyau
    echo -e "\n[2.6/17] Compilation des modules du noyau..."
    make -j$(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules

read -p "Appuie sur Entrée pour continuer..."

    # Sous-étape 2.7 : Installation des modules dans le rootfs
    echo -e "\n[2.7/17] Installation des modules dans le rootfs QEMU..."
    mkdir -p ${OUTDIR}/rootfs
    sudo make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_PATH=${OUTDIR}/rootfs modules_install

    # Vérification : Les modules doivent être installés dans /lib/modules
    if [ ! -d "${OUTDIR}/rootfs/lib/modules" ]; then
        echo "ERREUR : Modules non installés dans ${OUTDIR}/rootfs !"
        read -p "Appuie sur Entrée pour continuer..."
        exit 1
    fi
    
#read -p "Appuie sur Entrée pour continuer..."

    # Sous-étape 2.8 : Compilation du Device Tree (virt.dtb pour QEMU)
    echo -e "\n[2.8/17] Compilation du Device Tree (virt.dtb)..."
    # Activer la compatibilité QEMU virt pour ARM64
	echo "CONFIG_ARCH_VIRT=y" >> .config
	make ARCH=${ARCH} olddefconfig -j$(nproc)
	
    make ARCH=${ARCH} dtbs -j$(nproc)
    
    # Vérification : Le fichier virt.dtb doit exister
    if [ ! -f "arch/${ARCH}/boot/dts/arm/virt.dtb" ]; then
        echo "ERREUR : Fichier virt.dtb non généré !"
        echo "					"
	read -p "Appuie sur Entrée pour continuer..."
        exit 1
    fi

    # Sous-étape 2.9 : Copie des fichiers compilés dans le dossier de sortie
    echo -e "\n[2.9/17] Copie des fichiers dans ${OUTDIR}..."
    cp arch/${ARCH}/boot/Image ${OUTDIR}/
    cp arch/${ARCH}/boot/dts/virt/virt.dtb ${OUTDIR}/qemu-virt.dtb  # Renommer pour cohérence

    # Vérification finale des fichiers compilés
    echo -e "\n Compilation du noyau terminée ! Vérification :"
    ls -lh ${OUTDIR}/Image ${OUTDIR}/qemu-virt.dtb
    ls -lh ${OUTDIR}/rootfs/lib/modules/
    echo "					"
    read -p "Appuie sur Entrée pour continuer..."
fi

echo "					"
read -p "Appuie sur Entrée pour continuer..."

# ------------------------------------------------------------------------------
echo "ÉTAPE 3 : PRÉPARATION DU ROOTFS (système de fichiers racine)"
# ------------------------------------------------------------------------------
echo "[4/17] Ajout du fichier Image dans le dossier de sortie"
echo "[5/17] Création du répertoire staging pour le rootfs"

# Supprimer le rootfs existant (réinitialisation complète)
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]; then
    echo "[6/17] Suppression du dossier rootfs existant (réinitialisation)..."
    sudo rm -rf ${OUTDIR}/rootfs
fi

# Création de la structure de dossiers obligatoire pour Linux
echo "[7/17] Création du dossier rootfs principal..."
mkdir -p "${OUTDIR}/rootfs"

echo "[8/17] Création des dossiers système obligatoires..."
mkdir -p "${OUTDIR}/rootfs"/{bin,dev,etc,home,lib,lib64,proc,sbin,sys,tmp,usr,var}
mkdir -p "${OUTDIR}/rootfs"/{usr/bin,usr/sbin,usr/lib}  # Sous-dossiers /usr
mkdir -p "${OUTDIR}/rootfs/var/log"                     # Dossier logs


echo "					"
read -p "Appuie sur Entrée pour continuer..."

# ------------------------------------------------------------------------------
echo "ÉTAPE 4 : COMPILATION ET INSTALLATION DE BUSYBOX"
# ------------------------------------------------------------------------------
cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]; then
    echo "[9/17] CLONAGE DU DÉPÔT BUSYBOX (version ${BUSYBOX_VERSION})..."
    git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
else
    cd busybox
fi

# Configuration de BusyBox (defconfig si pas de config existante)
echo "[10/17] Configuration de BusyBox..."
if [ ! -f .config ]; then 
    make defconfig  # Créer la config par défaut SEULEMENT si elle n'existe pas
fi

# Compilation de BusyBox (cross-compilation ARM64)
echo "[11/17] Compilation de BusyBox..."
make -j$(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}

# Installation de BusyBox dans le rootfs
echo "[12/17] Installation de BusyBox dans ${OUTDIR}/rootfs..."
make CONFIG_PREFIX="${OUTDIR}/rootfs" ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install


echo "FIN Etape 4: COMPILATION ET INSTALLATION DE BUSYBOX					"
read -p "Appuie sur Entrée pour continuer..."  

# Vérification des dépendances de bibliothèques BusyBox
echo "[13/17] Vérification des dépendances de bibliothèques BusyBox..."
echo "FIN"
${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep "Shared library"
echo "test"
#aarch64-none-linux-gnu-readelf  -a   /home/tchuinkou/aeld/rootfs/bin/busybox | grep "Shared library"  

echo "					"
read -p "Appuie sur Entrée pour continuer..."  
# ------------------------------------------------------------------------------
echo " ÉTAPE 5 : CRÉATION DES PÉRIPHÉRIQUES (/dev)"
# ------------------------------------------------------------------------------
# Les device nodes permettent au noyau/BusyBox de communiquer avec le matériel virtuel (QEMU)
echo "[14/17] Création des device nodes dans ${DEV_DIR}..."
cd "${OUTDIR}/rootfs/dev"

# Création des périphériques essentiels (mode 666 = lecture/écriture pour tous)
sudo mknod -m 666 "${DEV_DIR}/console" c 5 1   # Console système
sudo mknod -m 666 "${DEV_DIR}/null"    c 1 3   # Périphérique null
sudo mknod -m 666 "${DEV_DIR}/tty"     c 5 0   # Terminal interactif
sudo mknod -m 666 "${DEV_DIR}/zero"    c 1 5   # Générateur d'octets nuls
sudo mknod -m 666 "${DEV_DIR}/random"  c 1 8   # Générateur de nombres aléatoires
sudo mknod -m 666 "${DEV_DIR}/urandom" c 1 9   # Générateur aléatoire non bloquant

echo "FIN Etape 5					"
read -p "Appuie sur Entrée pour continuer..."  

# ------------------------------------------------------------------------------
echo "# ÉTAPE 6 : COMPILATION DE L'UTILITAIRE "writer" "
# ------------------------------------------------------------------------------
echo "					"
read -p "Appuie sur Entrée pour continuer..."  
echo "[15/17] Compilation de l'utilitaire writer..."
cd "${WRITER_DIR}" 
make clean 2>/dev/null  # Nettoyage des anciennes compilations (sans afficher erreurs)
make all -j$(nproc)     # Compilation parallèle

# Vérification : Le fichier writer doit exister
if [ ! -f "${WRITER_DIR}/writer" ]; then
    echo "ERREUR : Échec de la compilation du writer !"
    echo "FIN Etape 5					"
	read -p "Appuie sur Entrée pour continuer..."  
    exit 1
fi

# ------------------------------------------------------------------------------
# ÉTAPE 7 : COPIE DES SCRIPTS FINDER DANS LE ROOTFS
# ------------------------------------------------------------------------------
echo "[16/17] Copie des scripts/executables finder dans /home du rootfs..."
cp /home/tchuinkou/aesd-assignments/finder-app/finder.sh        ${OUTDIR}/rootfs/home/
cp /home/tchuinkou/aesd-assignments/finder-app/finder-test.sh   ${OUTDIR}/rootfs/home/
cp /home/tchuinkou/aesd-assignments/finder-app/writer.sh        ${OUTDIR}/rootfs/home/
cp /home/tchuinkou/aesd-assignments/finder-app/writer           ${OUTDIR}/rootfs/home/
cp /home/tchuinkou/aesd-assignments/finder-app/conf/assignment.txt  ${OUTDIR}/rootfs/home/
cp /home/tchuinkou/aesd-assignments/finder-app/manual-linux.sh  ${OUTDIR}/rootfs/home/
cp /home/tchuinkou/aesd-assignments/finder-app/start-qemu-app.sh ${OUTDIR}/rootfs/home/
cp /home/tchuinkou/aesd-assignments/finder-app/start-qemu-terminal.sh ${OUTDIR}/rootfs/home/
cp /home/tchuinkou/aesd-assignments/finder-app/autorun-qemu.sh  ${OUTDIR}/rootfs/home/

# ------------------------------------------------------------------------------
# ÉTAPE 8 : CONFIGURATION DES PERMISSIONS ET CRÉATION DE L'INITRAMFS
# ------------------------------------------------------------------------------


	# === Ajouter cette partie dans ton script ===
	# Créer le fichier /init (point d'entrée du noyau) dans le rootfs
	echo "[17.1/17] Création du fichier /init (obligatoire pour l'initramfs)..."
	read -p "Appuie sur Entrée pour continuer..."  

	# 1. Vérifier/créer les dossiers minimaux requis dans le rootfs
	#sudo mkdir -p ${OUTDIR}/rootfs/{bin,dev,proc,sys,tmp}

	# 2. Copier un shell ARM64 dans le rootfs (OBLIGATOIRE — adapte le chemin de ta toolchain !)
	# Chemin typique de la toolchain ARM64 : /usr/aarch64-none-linux-gnu/bin/sh
	# Si tu n'as pas cette toolchain : installer avec sudo apt install gcc-aarch64-linux-gnu


	# 3. Créer le fichier /init (script shell minimaliste)
	# ⚠️ IMPORTANT : Le 'EOF' de fermeture DOIT être sur une ligne SEULE, sans espace/tabulation avant/après
	# Écrire ligne par ligne dans /init (évite tout problème de syntaxe)
	sudo echo '#!/bin/sh' > ${OUTDIR}/rootfs/init
	sudo echo 'echo "========================================"' >> ${OUTDIR}/rootfs/init
	sudo echo 'echo " Initramfs ARM64 démarré avec succès!"' >> ${OUTDIR}/rootfs/init
	sudo echo 'echo "========================================"' >> ${OUTDIR}/rootfs/init
	sudo echo 'mount -t proc none /proc' >> ${OUTDIR}/rootfs/init
	sudo echo 'mount -t sysfs none /sys' >> ${OUTDIR}/rootfs/init
	sudo echo 'mount -t devtmpfs none /dev' >> ${OUTDIR}/rootfs/init
	sudo echo 'echo " QEMU est actif (Ctrl+C dans le terminal pour quitter)"' >> ${OUTDIR}/rootfs/init
	sudo echo 'while true; do sleep 60; done' >> ${OUTDIR}/rootfs/init

	# 4. Rendre /init exécutable et attribuer les droits root
	sudo chmod +x ${OUTDIR}/rootfs/init
	sudo chown root:root ${OUTDIR}/rootfs/init

	# Vérification du fichier /init
	echo " Fichier /init créé : ${OUTDIR}/rootfs/init"
	ls -lh ${OUTDIR}/rootfs/init
	# === Fin de la partie à ajouter ===

# Attribution des droits root (obligatoire pour le rootfs Linux)
	echo "[17/17] Attribution des permissions root au rootfs..."
	sudo chown -R root:root ${OUTDIR}/rootfs/

	# Création de l'initramfs.cpio.gz (image compressée du rootfs pour QEMU)
	echo "[FINAL] Création de l'initramfs.cpio.gz..."
	echo "					"
	read -p "Appuie sur Entrée pour continuer..."  
	
	# === Partie adaptée (corrections clés) ===
	# 1. Vérifier que le dossier rootfs existe (évite les erreurs)
	if [ ! -d "${OUTDIR}/rootfs" ]; then
	    echo "ERREUR : Dossier rootfs introuvable à ${OUTDIR}/rootfs"
	    exit 1
	fi
	
	# 2. Se placer dans le rootfs et générer le cpio (avec vérifications)
	cd "${OUTDIR}/rootfs" || { echo "ERREUR : Impossible d'accéder à ${OUTDIR}/rootfs"; exit 1; }
	
	# Générer le cpio (format newc, droits root, sans erreurs de fichiers spéciaux)
	find . -mindepth 1 -print0 | cpio --null -ov --format=newc --owner root:root 2>/dev/null > "${OUTDIR}/initramfs.cpio"

	# 3. Retourner dans OUTDIR et compresser en gz (forcer l'écrasement)
	cd "${OUTDIR}" || exit 1
	gzip -f initramfs.cpio  # Compresser l'initramfs (écraser si déjà existant)
	
	# 4. Vérification finale (confirmer la création)
	if [ -f "${OUTDIR}/initramfs.cpio.gz" ]; then
	    echo " initramfs.cpio.gz créé avec succès : ${OUTDIR}/initramfs.cpio.gz"
	    ls -lh "${OUTDIR}/initramfs.cpio.gz"  # Affiche la taille du fichier (vérification visuelle)
	else
	    echo " Échec de la création de initramfs.cpio.gz"
	    exit 1
	fi

	#cd "$OUTDIR/rootfs"
	#find . -print0 | cpio --null -ov --format=newc --owner root:root > "${OUTDIR}/initramfs.cpio"
	#cd "$OUTDIR"
	#gzip -f initramfs.cpio  # Compresser l'initramfs (écraser si déjà existant)

echo -e "\nSCRIPT TERMINÉ ! Tous les fichiers sont prêts dans ${OUTDIR} :"
echo "   - Noyau : ${OUTDIR}/Image"
echo "   - Device Tree : ${OUTDIR}/qemu-virt.dtb"
echo "   - Initramfs : ${OUTDIR}/initramfs.cpio.gz"
echo "   - Rootfs : ${OUTDIR}/rootfs"
