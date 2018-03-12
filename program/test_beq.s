.text
# Pour les tests ne pas utiliser le registre $1
# cas rs =rt
addi $2, $0, 1
addi $3, $0, 1
beq $2, $3, moins
add $28, $2, $3

moins :
sub $28, $3, $2

# cas rs != rt
addi $2, $2, 1
beq $2, $3, moins2
add $28, $2, $3

moins2 :
sub $28, $2, $3

# pout_start
# 00000000
# 00000003
# pout_end
