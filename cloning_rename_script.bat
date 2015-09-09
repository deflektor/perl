rem Rename script after cloning of server
set path=%path%;C:\Program Files (x86)\GnuWin32\bin
pushd .
cd C:\Program Files (x86)\Business Objects\Tomcat55\webapps
"C:\Program Files (x86)\GnuWin32\bin\find.exe" . -name "web.xml" | xargs perl -p -i.bak -e "s/AVW3088T/BODEV/ig"
"C:\Program Files (x86)\GnuWin32\bin\find.exe" . -name "web.xml" | xargs perl -p -i.bak -e "s/BOTEST/BODEV/ig"
rem "C:\Program Files (x86)\GnuWin32\bin\find.exe" . -name "web.xml" | xargs perl -p -i.bak -e "s/(\<param-name\>vintela.enabled\<\/param-name\>\n\s*?\<param-value\>)false/$1true/g"
popd