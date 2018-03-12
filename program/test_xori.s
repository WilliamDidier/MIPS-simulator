.text
# Pour les tests ne pas utiliser le registre $1
addi $2, $0, 1
xori $28, $2, 2
xori $28, $2, 1
# pout_start
# 00000003
# 00000000
# pout_end
