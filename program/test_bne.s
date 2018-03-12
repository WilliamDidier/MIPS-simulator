.text
# Pour les tests ne pas utiliser le registre $1
# cas rs =rt

addi $2, $0, 1
addi $3, $0, 1

bne $2, $3, label1
lui $28, 0xFFFF
j fintest1

label1 :
lui $28, 0x0001
fintest1 :

# cas rs != rt
addi $2, $2, 1
bne $2, $3, label2
lui $28, 0xFFFF
j fintest2

label2 :
lui $28, 0x0001
fintest2 :

# pout_start
# FFFF0000
# 00010000
# pout_end
