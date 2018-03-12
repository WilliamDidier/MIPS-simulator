.text
# Pour les tests ne pas utiliser le registre $1

lui $2, 0x0001
lui $3, 0x0002

#cas rs < rt : on attend 0x00000001
slt $28, $2, $3

#cas rs = rt : on attend 0x00000000
slt $28, $2, $2

#cas rs > rt : on attend 0x00000000
slt $28, $3, $2

# pout_start
# 00000001
# 00000000
# 00000000
# pout_end
