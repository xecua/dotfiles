:let s:file_path = expand('%:p:h')
:let s:package_name = substitute(substitute(s:file_path, '.*src/main/java/\?', '', ''), '/', '.', 'g')
:if s:file_path =~ '.*src/main/java/\?' && s:package_name != '' " in project
:  %s@PACKAGE_NAME@\=s:package_name@
:else " otherwise
:  ,2delete " remove package declaration
:endif
:%s@PUBLIC_CLASS@\=expand('%:t:r')@
package PACKAGE_NAME;

public class PUBLIC_CLASS {
    public static void main(String[] args) {
        
    }
}

