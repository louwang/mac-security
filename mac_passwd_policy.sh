#!/bin/bash

#############################
# Password Policy Settings ##
#############################

MAX_FAILED=10                  # 5 max failed logins before locking
LOCKOUT=120                    # 2min lockout
MIN_LENGTH=8                    # at least 16 chars for password
MIN_NUMERIC=1                   # at least 0 number in password
MIN_ALPHA_LOWER=1               # at least 0 lower case letter in password
MIN_UPPER_ALPHA=1               # at least 0 upper case letter in password
MIN_SPECIAL_CHAR=0             # at least 0 special character in password

exemptAccount1="ENTER_EXEMPT_ACCOUNT"          #Exempt account used for remote management. CHANGE THIS TO YOUR EXEMPT ACCOUNT



for user in $(dscl . list /Users UniqueID | awk '$2 >= 500 {print $1}'); do
    if [ "$user" != "$exemptAccount1" ]; then

    #Check if current plist is installed by comparing the current variables to the new ones

    #MIN_SPECIAL_CHAR
    currentMinSpecialChar=$(sudo pwpolicy -u "$user" -getaccountpolicies | grep "<string>policyAttributePassword matches '(.*[^a-zA-Z0-9].*){$MIN_SPECIAL_CHAR,}+'</string>" |  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' )
    newMinSpecialChar="<string>policyAttributePassword matches '(.*[^a-zA-Z0-9].*){$MIN_SPECIAL_CHAR,}+'</string>"

    #MIN_UPPER_ALPHA
    currentUpperLimit=$(sudo pwpolicy -u "$user" -getaccountpolicies | grep "<string>policyAttributePassword matches '(.*[A-Z].*){$MIN_UPPER_ALPHA,}+'</string>" |  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' )
    newUpperLimit="<string>policyAttributePassword matches '(.*[A-Z].*){$MIN_UPPER_ALPHA,}+'</string>"

    #MIN_ALPHA_LOWER
    currentLowerLimit=$(sudo pwpolicy -u "$user" -getaccountpolicies | grep "<string>policyAttributePassword matches '(.*[a-z].*){$MIN_ALPHA_LOWER,}+'</string>" |  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' )
    newLowerLimit="<string>policyAttributePassword matches '(.*[a-z].*){$MIN_ALPHA_LOWER,}+'</string>"

    #MIN_NUMERIC
    currentNumLimit=$(sudo pwpolicy -u "$user" -getaccountpolicies | grep "<string>policyAttributePassword matches '(.*[0-9].*){$MIN_NUMERIC,}+'</string>" |  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' )
    newNumLimit="<string>policyAttributePassword matches '(.*[0-9].*){$MIN_NUMERIC,}+'</string>"

    #MIN_LENGTH
    currentMinLength=$(sudo pwpolicy -u "$user" -getaccountpolicies | grep "<string>policyAttributePassword matches '.{$MIN_LENGTH,}+'</string>" |  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' )
    newMinLength="<string>policyAttributePassword matches '.{$MIN_LENGTH,}+'</string>"

    #LOCKOUT
    currentLockOut=$(sudo pwpolicy -u "$user" -getaccountpolicies | grep "<integer>$LOCKOUT</integer>" |  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' )
    newLockOut="<integer>$LOCKOUT</integer>"

    #MAX_FAILED
    currentMaxFailed=$(sudo pwpolicy -u "$user" -getaccountpolicies | grep "<integer>$MAX_FAILED</integer>" |  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' )
    newMaxFailed="<integer>$MAX_FAILED</integer>"


    isPlistNew=0

    if [ "$currentPwHistory" == "$newPwHistory" ]; then
      echo "PW_History is the same"
    else
      echo "PW_History is NOT the same"
      echo "current: $currentPwHistory"
      echo "new: $newPwHistory"
      isPlistNew=1
    fi

    if [ "$currentMinSpecialChar" == "$newMinSpecialChar" ]; then
      echo "MIN_SPECIAL_CHAR is the same"
    else
      echo "MIN_SPECIAL_CHAR is NOT the same"
      echo "current: $currentMinSpecialChar"
      echo "new: $newMinSpecialChar"
      isPlistNew=1
    fi

    if [ "$currentUpperLimit" == "$newUpperLimit" ]; then
      echo "MIN_UPPER_ALPHA is the same"
    else
      echo "MIN_UPPER_ALPHA is NOT the same"
      echo "current: $currentUpperLimit"
      echo "new: $newUpperLimit"
      isPlistNew=1
    fi

    if [ "$currentLowerLimit" == "$newLowerLimit" ]; then
      echo "MIN_ALPHA_LOWER is the same"
    else
      echo "MIN_ALPHA_LOWER is NOT the same"
      echo "current: $currentLowerLimit"
      echo "new: $newLowerLimit"
      isPlistNew=1
    fi

    if [ "$currentNumLimit" == "$newNumLimit" ]; then
      echo "MIN_NUMERIC is the same"
    else
      echo "MIN_NUMERIC is NOT the same"
      echo "current: $currentNumLimit"
      echo "new: $newNumLimit"
      isPlistNew=1
    fi

    if [ "$currentMinLength" == "$newMinLength" ]; then
      echo "MIN_LENGTH is the same"
    else
      echo "MIN_LENGTH is NOT the same"
      echo "current: $currentMinLength"
      echo "new: $newMinLength"
      isPlistNew=1
    fi

    if [ "$currentPwExpire" == "$newPwExpire" ]; then
      echo "PW_Expire is the same"
    else
      echo "PW_Expire is NOT the same"
      echo "current: $currentPwExpire"
      echo "new: $newPwExpire"
      isPlistNew=1
    fi

    if [ "$currentLockOut" == "$newLockOut" ]; then
      echo "LOCKOUT is the same"
    else
      echo "LOCKOUT is NOT the same"
      echo "current: $currentLockOut"
      echo "new: $newLockOut"
      isPlistNew=1
    fi

    if [ "$currentMaxFailed" == "$newMaxFailed" ]; then
      echo "MAX_FAILED is the same"
    else
      echo "MAX_FAILED is NOT the same"
      echo "current: $currentMaxFailed"
      echo "new: $newMaxFailed"
      isPlistNew=1
    fi




    if [ "$isPlistNew" -eq "1" ]; then


    # Creates plist using variables above
    echo "<dict>
    <key>policyCategoryAuthentication</key>
      <array>
      <dict>
        <key>policyContent</key>
        <string>(policyAttributeFailedAuthentications &lt; policyAttributeMaximumFailedAuthentications) OR (policyAttributeCurrentTime &gt; (policyAttributeLastFailedAuthenticationTime + autoEnableInSeconds))</string>
        <key>policyIdentifier</key>
        <string>Authentication Lockout</string>
        <key>policyParameters</key>
      <dict>
      <key>autoEnableInSeconds</key>
      <integer>$LOCKOUT</integer>
      <key>policyAttributeMaximumFailedAuthentications</key>
      <integer>$MAX_FAILED</integer>
      </dict>
    </dict>
    </array>



      <key>policyCategoryPasswordContent</key>
    <array>
      <dict>
      <key>policyContent</key>
        <string>policyAttributePassword matches '.{$MIN_LENGTH,}+'</string>
      <key>policyIdentifier</key>
        <string>Has at least $MIN_LENGTH characters</string>
      <key>policyParameters</key>
      <dict>
        <key>minimumLength</key>
        <integer>$MIN_LENGTH</integer>
      </dict>
      </dict>


      <dict>
      <key>policyContent</key>
        <string>policyAttributePassword matches '(.*[0-9].*){$MIN_NUMERIC,}+'</string>
      <key>policyIdentifier</key>
        <string>Has a number</string>
      <key>policyParameters</key>
      <dict>
      <key>minimumNumericCharacters</key>
        <integer>$MIN_NUMERIC</integer>
      </dict>
      </dict>


      <dict>
      <key>policyContent</key>
        <string>policyAttributePassword matches '(.*[a-z].*){$MIN_ALPHA_LOWER,}+'</string>
      <key>policyIdentifier</key>
        <string>Has a lower case letter</string>
      <key>policyParameters</key>
      <dict>
      <key>minimumAlphaCharactersLowerCase</key>
        <integer>$MIN_ALPHA_LOWER</integer>
      </dict>
      </dict>


      <dict>
      <key>policyContent</key>
        <string>policyAttributePassword matches '(.*[A-Z].*){$MIN_UPPER_ALPHA,}+'</string>
      <key>policyIdentifier</key>
        <string>Has an upper case letter</string>
      <key>policyParameters</key>
      <dict>
      <key>minimumAlphaCharacters</key>
        <integer>$MIN_UPPER_ALPHA</integer>
      </dict>
      </dict>


      <dict>
      <key>policyContent</key>
        <string>policyAttributePassword matches '(.*[^a-zA-Z0-9].*){$MIN_SPECIAL_CHAR,}+'</string>
      <key>policyIdentifier</key>
        <string>Has a special character</string>
      <key>policyParameters</key>
      <dict>
      <key>minimumSymbols</key>
        <integer>$MIN_SPECIAL_CHAR</integer>
      </dict>
      </dict>
	  

    </array>
    </dict>" > /private/var/tmp/pwpolicy.plist #save the plist temp

    chmod 777 /private/var/tmp/pwpolicy.plist


        pwpolicy -u "$user" -clearaccountpolicies
        pwpolicy -u "$user" -setaccountpolicies /private/var/tmp/pwpolicy.plist
        fi
    fi
done

rm /private/var/tmp/pwpolicy.plist

echo "Password policy successfully applied. Run \"sudo pwpolicy -u <user> -getaccountpolicies\" to see it."
exit 0
