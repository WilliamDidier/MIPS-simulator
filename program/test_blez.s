.text
# Pour les tests ne pas utiliser le registre $1

# cas rs < 0
addi $2, $0, -1
blez $2, moins
addi $28, $0, 2
j etape2

moins :
addi $28, $0, 1

# cas rs = 0
etape2 :
xor $2, $2, $2
blez $2, moins2
addi $28, $0, 4
j etape3

moins2 :
addi $28, $0, 3

# cas rs > 0
etape3 :
addi $2, $2, 1
blez $2, moins3
addi $28, $0, 4

moins3 :
addi $28, $0, 5

# pout_start
# 00000001
# 00000003
# 00000004
# pout_end
