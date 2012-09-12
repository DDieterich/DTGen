
ROOT_LIST="install_owner install_user uninstall_owner uninstall_user"
TDIR_LIST="DB_Integ MT_Integ DODMT_Integ DB_NoInteg MT_NoInteg DODMT_NoInteg"
TDIR_LIST="DB_Integ MT_Integ DODMT_Integ"

for TDIR in ${TDIR_LIST}
do
   cd ${TDIR}
   for ROOT in ${ROOT_LIST}
   do
      mv ${ROOT}.gold ${ROOT}.old
      mv ${ROOT}.log ${ROOT}.gold
   done
   cd ${OLDPWD}
done
