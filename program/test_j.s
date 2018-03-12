.text
# Pour les tests ne pas utiliser le registre $1
addi $2, $0, 0x0001
addi $3, $0, 0x0010
j moins
add $28, $2, $3
moins :
sub $28, $3, $2
# pout_start
# 0000000F
# pout_end
