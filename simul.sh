#!/bin/bash
# file: simul.sh
# start host 0
./freechains-host start /tmp/myhost
# switch to another terminal
# creates a cryptographic identity
./freechains keys pubpvt "Senha"
# create a chain pub - as Public Forum
./freechains chains join '#receitas''31D9850C83A76B671A66AF0064628624A4A3383A9C5AFF262A44EA3FF99BDAF8EC99532686B3600FFAA3FE19FFF123BCFA86D984A29BE2B2967BB247C629E00A'
./freechains chain '#receitas' post inline "Este forum debate P2P" --sign='31D9850C83A76B671A66AF0064628624A4A3383A9C5AFF262A44EA3FF99BDAF8EC99532686B3600FFAA3FE19FFF123BCFA86D984A29BE2B2967BB247C629E00A'
./freechains chain '#receitas' consensus
./freechains chain '#receitas' get payload 1_114560105F6E5C3C22277A7C7EDD669E8D3D8A9C3173E3D37F58B15BE20B4B11
./freechains chain '#receitas' reps 'EC99532686B3600FFAA3FE19FFF123BCFA86D984A29BE2B2967BB247C629E00A'
./freechains-host now
#
# start host1
# switch to another terminal
./freechains-host --port=8331 start /tmp/host1
./freechains keys pubpvt "Senha1"
./freechains --host=localhost:8330 peer localhost:8331 send '#receitas'
./freechains chain '#receitas' consensus
./freechains chain '#receitas' get payload 1_114560105F6E5C3C22277A7C7EDD669E8D3D8A9C3173E3D37F58B15BE20B4B11 
./freechains-host now
./freechains chain '#receitas' reps 'AA31C07E676000FE72A3D4DF228589A0F52EBDF778C195EDCE2BEA3D528E9917'
#
# start host2
# switch to another terminal
./freechains-host --port=8332 start /tmp/host2
./freechains keys pubpvt "Senha2"
./freechains --host=localhost:8332 chains join '#receitas' '31D9850C83A76B671A66AF0064628624A4A3383A9C5AFF262A44EA3FF99BDAF8EC99532686B3600FFAA3FE19FFF123BCFA86D984A29BE2B2967BB247C629E00A'
./freechains --host=localhost:8330 peer localhost:8332 send '#receitas'
./freechains '#receitas' consensus
./freechains chain '#receitas' get payload 2_AD15A5C25849FAB22158488A12B172A505BB0EC3B1F3913E4062B3CE3B640D1C
./freechains chain '#receitas' post inline "Brigadeiro" '6873A48D616230CCB889261A1B1FD2C221BC911790E41AE447AAFF2CB44417199EE78369404DE350383ED95EEF59E890AF758B20BC7C0CB8759E733395B48AEB'
./freechains chain '#receitas' reps '9EE78369404DE350383ED95EEF59E890AF758B20BC7C0CB8759E733395B48AEB'
./freechains chain '#receitas' post inline "Bolo facil" --sign='6873A48D616230CCB889261A1B1FD2C221BC911790E41AE447AAFF2CB44417199EE78369404DE350383ED95EEF59E890AF758B20BC7C0CB8759E733395B48AEB'
./freechains-host now 
./freechains chain '#receitas' post inline "Bolo de cenoura" --sign='6873A48D616230CCB889261A1B1FD2C221BC911790E41AE447AAFF2CB44417199EE78369404DE350383ED95EEF59E890AF758B20BC7C0CB8759E733395B48AEB'
./freechains chain '#receitas' consensus
# switch to another terminal
./freechains keys pubpvt "Senha3"
./freechains --host=localhost:8333 chains join '#receitas' 'A6A21CF432E882BADF40CED3D26DAC15F955C52061227A6A725CFD61ED71610F290C2B59D15B8E1FB04E12C3B5B5D7BB16AC4336D7EA0B90A329950D167CFD57'
./freechains --host=localhost:8330 peer localhost:8333 send '#receitas'
./freechains '#receitas' consensus
./freechains chain '#receitas' get payload '11_D139AD33647CE7840029DD3E8A679CAC5E790C3F61963997AE1C57EA7E5F3288'
./freechains chain '#receitas' post inline "Torta de limao" '6873A48D616230CCB889261A1B1FD2C221BC911790E41AE447AAFF2CB44417199EE78369404DE350383ED95EEF59E890AF758B20BC7C0CB8759E733395B48AEB'
./freechains chain '#receitas' reps '290C2B59D15B8E1FB04E12C3B5B5D7BB16AC4336D7EA0B90A329950D167CFD57'
./freechains chain '#receitas' post inline "8333:msg2" --sign='A6A21CF432E882BADF40CED3D26DAC15F955C52061227A6A725CFD61ED71610F290C2B59D15B8E1FB04E12C3B5B5D7BB16AC4336D7EA0B90A329950D167CFD57'
./freechains-host now 
./freechains chain '#receitas' post inline "8333:msg3" --sign='A6A21CF432E882BADF40CED3D26DAC15F955C52061227A6A725CFD61ED71610F290C2B59D15B8E1FB04E12C3B5B5D7BB16AC4336D7EA0B90A329950D167CFD57'
./freechains chain '#receitas' consensus