.text
# Pour les tests ne pas utiliser le registre $1
lui $2, 0x0001
addi $3, $0, 1
sll $28, $2, $3

# pout_start
# 00020000
# pout_end
