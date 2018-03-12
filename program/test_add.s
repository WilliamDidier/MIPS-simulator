.text
# Pour les tests ne pas utiliser le registre $1

lui $2, 0x0001
lui $3, 0x0002
add $28, $2, $3

lui $4, 0x1001
lui $5, 0x1002
add $28, $4, $5
addu $28, $4, $5

lui $6, 0x8001
addu $28, $6, $2


# pout_start
# 00030000
# 20030000
# 20030000
# 80020000
# pout_end
