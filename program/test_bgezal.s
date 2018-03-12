.text
# Pour les tests ne pas utiliser le registre $1
#fonction
fonction :
addi $27, $0, 0x0001


# cas rs < 0
lui $2, 0x1001
blez $2, moins
addi $2, 0x0002

moins :
sub $2, 0x0001

# cas rs = 0, rs négatif
blez $2, moins
addi $2, 0x0003

moins :
sub $2, 0x0001

# cas rs = 0, rs positif
lui $2, 0x0001
blez $2, moins
addi $2, 0x0004

moins :
sub $2, 0x0001

# cas rs > 0
blez $2, moins
addi $2, 0x0005

moins :
sub $2, 0x0001

# pout_start
# 1000100E
# 1000100F
# 0000100F
# 0000100E
# pout_end
