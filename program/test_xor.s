.text
# Pour les tests ne pas utiliser le registre $1
lui $2, 0x0001
lui $3, 0x0002
xor $28, $2, $3
xor $28, $2, $2
# pout_start
# 00030000
# 00000000
# pout_end
