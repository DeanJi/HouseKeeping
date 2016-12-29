#!/bin/csh -f

#****************************************************************************
# Source Config File 
#****************************************************************************

set APP_NAME=XXXXX
set HK_LOGPATH=$$APP_HOME$$/logs
set HKLOG_DATE=`date '+%y%m%d%H%M'`
set HKLOGFILE=$HK_LOGPATH/${APP_NAME}_${HKLOG_DATE}.log


set HKLOG_DATE=`date '+%y%m%d%H%M'`

#======================================================================
#       Main Control Section
#======================================================================

echo "Executing $0 ... " `date` |& tee -a $HKLOGFILE
cd $$APP_HOME$$/HouseKeeping
set rc=0
set PID=$$
set TMP_LIST=/tmp/${PID}.lst
foreach LINE ("`cat XXXXX_HKeep.lst`")
	echo $LINE
    set STATUS=OK
    set HKACTION=  (`echo "$LINE" | awk '{print $1}'`)

	switch("$HKACTION")
        case FD:

           	set HKAGE = (`echo "$LINE" | awk '{print $2}'`)
           	set HK_DIR = (`echo "$LINE" | awk '{print $3}'`)

      		if (! -d ${HK_DIR}) then
           		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" |& tee -a $HKLOGFILE
           		echo "*** ERROR! Directory: ${HK_DIR} does not exist! ***" |& tee -a $HKLOGFILE
           		set STATUS=BAD
        	endif
        	breaksw

        case FZ:
           	set HKAGE = (`echo "$LINE" | awk '{print $2}'`)
           	set HK_DIR = (`echo "$LINE" | awk '{print $3}'`)

      		if (! -d ${HK_DIR}) then
           		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" |& tee -a $HKLOGFILE
           		echo "*** ERROR! Directory: ${HK_DIR} does not exist! ***" |& tee -a $HKLOGFILE
           		set STATUS=BAD
        	endif
        	breaksw

		default:
			echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" |& tee -a $HKLOGFILE
            echo "*** ERROR : Action should be FD/FZ \! Please check\!***" |& tee -a $HKLOGFILE
            set STATUS = BAD
	endsw


	switch ($HKACTION)
    	case FD:
        case FZ:


        if (${HKACTION} == "FD") then
        	echo "Performing File Deletion (FD)....." |& tee -a $HKLOGFILE
            echo "Current Directory: " ${HK_DIR} |& tee -a $HKLOGFILE
           	#find ${HK_DIR}  -type f -mtime +$HKAGE -exec rm -f {} \; |& tee -a $HKLOGFILE
           	find ${HK_DIR}  -type f -mtime +$HKAGE -print > $TMP_LIST
           	          	
           	set j=1                        
           	set nRecordCount=`cat $TMP_LIST | wc -l`
           	while ($j <= $nRecordCount)
							set FILE=`cat $TMP_LIST | head -$j | tail -1`
							@ j++
							echo "File Name is $FILE"
							rm "$FILE"
							if ( $status != 0) then
								echo "Failed to remove $FILE"
								set rc=-1
							endif
		        end

		   endif

set TODAY = `date '+%y%m%d'`

        if (${HKACTION} == "FZ") then
        	  echo "Zipping files older than." ${HKAGE} |& tee -a $HKLOGFILE
            echo "Current Directory: " ${HK_DIR} |& tee -a $HKLOGFILE
           	# find ${HK_DIR} -type f -mtime +$HKAGE -exec  bzip2 {} \; |& tee -a $HKLOGFILE
           	find ${HK_DIR}  -type f ! -name "*.bz2" -mtime +$HKAGE -print > $TMP_LIST
           	
           	set j=1                        
           	set nRecordCount=`cat $TMP_LIST | wc -l`
           	while ($j <= $nRecordCount)
							set FILE=`cat $TMP_LIST | head -$j | tail -1`
							set new_file = `echo ${FILE}.${TODAY}`
							mv ${FILE} ${new_file}
							@ j++
							echo "Compressing file $FILE" 
							bzip2 "${new_file}"
							if ( $status != 0) then
								echo "Failed to compress $FILE"
								set rc=-1
							endif
		        end
		    endif
        endsw

end
    rm  $TMP_LIST
exit $rc
