% Install distribution files into web directory
% !zip -r F2_LAME_standalone/for_redistribution/MyAppInstaller_web.app web/F2_LAME.zip
% copyfile('F2_LAME_standalone/for_redistribution/MyAppInstaller_web.exe','web/F2_LAME.exe');
% copyfile('F2_LAME_standalone/for_redistribution/MyAppInstaller_web.install','web/F2_LAME.install');
copyfile('F2_LAME.mlappinstall','web/');
!scp web/* whitegr@ar-pc90328.slac.stanford.edu:~/public_html/F2apps/