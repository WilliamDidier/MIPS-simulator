.text
# Pour les tests ne pas utiliser le registre $1

addi $2, $0, 1


#cas rs < imm : on attend 0x00000001
slti $28, $2, 2

#cas rs = rt : on attend 0x00000000
slti $28, $2, 1

#cas rs > rt : on attend 0x00000000
slti $28, $2, 0

# pout_start
# 00000001
# 00000000
# 00000000
# pout_end
