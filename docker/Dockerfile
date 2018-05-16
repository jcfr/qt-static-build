FROM dockbuild/centos5-devtoolset2-gcc4:latest
MAINTAINER CommonTK Community <ctk-developers@commontk.org>
# Build and package the CTK AppLauncher

WORKDIR /usr/src

ARG QT_INSTALL_DIR=/usr/src/qt-everywhere-opensource-release-build-4.8.6

ARG DEBIAN_FRONTEND=noninteractive

RUN \
 yum update -y && \
 #
 # Qt dependencies: https://doc.qt.io/archives/qt-4.8/requirements-x11.html
 #
 yum install -y \
   libX11-devel \
   libXt-devel \
   libXext-devel \
   libXrender-devel \
 && \
 #
 # Download Qt sources
 #
 QT_ROOT=qt-everywhere-opensource-src-4.8.6 && \
 curl -LO http://packages.kitware.com/download/item/6175/${QT_ROOT}.tar.gz && \
 echo "2edbe4d6c2eff33ef91732602f3518eb  ${QT_ROOT}.tar.gz" > ${QT_ROOT}.tar.gz.md5 && \
 md5sum -c ${QT_ROOT}.tar.gz.md5 && \
 tar -xzvf ${QT_ROOT}.tar.gz && \
 rm -f ${QT_ROOT}.tar.gz && \
 rm -f ${QT_ROOT}.tar.gz.md5 && \
 QT_SRC_DIR=/usr/src/qt-everywhere-opensource-release-src-4.8.6 && \
 mv ${QT_ROOT} ${QT_SRC_DIR} && \
 #
 # Build Qt
 #
 cd /usr/src && \
 mkdir ${QT_INSTALL_DIR} && \
 cd ${QT_SRC_DIR} && \
 LD=${CXX} ./configure \
   -prefix ${QT_INSTALL_DIR} \
   -confirm-license -opensource \
   -static \
   -release \
   -no-largefile \
   -no-exceptions \
   -no-accessibility \
   -no-sql-db2 \
   -no-sql-ibase \
   -no-sql-mysql \
   -no-sql-oci \
   -no-sql-odbc \
   -no-sql-psql \
   -no-sql-sqlite \
   -no-sql-sqlite2 \
   -no-sql-sqlite_symbian \
   -no-sql-tds \
   -no-qt3support \
   -no-xmlpatterns \
   -no-multimedia \
   -no-audio-backend \
   -no-phonon \
   -no-phonon-backend \
   -no-svg \
   -no-webkit \
   -no-javascript-jit \
   -no-script \
   -no-scripttools \
   -no-declarative \
   -no-gif \
   -no-libtiff \
   -no-libmng \
   -no-openssl \
   -no-nis \
   -no-cups \
   -no-dbus \
   -no-opengl \
   -no-openvg \
   -nomake demos \
   -nomake examples \
   -no-gtkstyle && \
  make -j$(grep -c processor /proc/cpuinfo) && \
  make install && \
  rm -rf ${QT_SRC_DIR} && \
  rm -rf ${QT_INSTALL_DIR}/q3porting.xml && \
  rm -rf ${QT_INSTALL_DIR}/demos && \
  rm -rf ${QT_INSTALL_DIR}/doc && \
  rm -rf ${QT_INSTALL_DIR}/examples && \
  rm -rf ${QT_INSTALL_DIR}/phrasebooks && \
  rm -rf ${QT_INSTALL_DIR}/tests && \
  rm -rf ${QT_INSTALL_DIR}/translations && \
  #
  # cleanup
  #
  yum clean all

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG IMAGE
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$IMAGE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.schema-version="1.0"

