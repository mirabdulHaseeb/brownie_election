from brownie import accounts, Election
from scripts.deploy import deploy_election


def test_can_deploy():
    contract = deploy_election()
    assert contract.electionName() == "Dapp Elections"
    assert contract.owner() == accounts[0]
    assert contract.state() == 0

def test_can_pay_fee():
    contract = deploy_election()
    tx = contract.payFee({"from": accounts[1], "value": 100})
    tx.wait(1)
    assert contract.balanceOf() == 100
    assert contract.candidates(accounts[1])["registered"] == True
    

def test_can_add_candidate():
    contract = deploy_election()
    tx = contract.payFee({"from": accounts[1], "value": 100})
    tx.wait(1)
    contract.addCandidate(accounts[1], "Bob")
    assert contract.getTotalCandidates() == 1
    assert contract.candidates(accounts[1])["registered"] == True
    assert contract.candidates(accounts[1])["name"] == "Bob"
    assert contract.candidates(accounts[1])["voteCount"] == 0
    
def test_can_register_voter():
    contract = deploy_election()
    assert contract.voters(accounts[2])["registered"] == False
    tx = contract.registerVoter(accounts[2])
    tx.wait(1)
    assert contract.voters(accounts[2])["registered"] == True

def test_can_vote():
    contract = deploy_election()
    tx = contract.registerVoter(accounts[2])
    tx.wait(1)
    tx1 = contract.payFee({"from": accounts[1], "value": 100})
    tx1.wait(1)
    contract.addCandidate(accounts[1], "Bob")
    tx3 = contract.startVote()
    tx3.wait(1)
    tx2 = contract.vote(accounts[1], {"from": accounts[2]})
    tx2.wait(1)
    assert contract.candidates(accounts[1])["voteCount"] == 1

def test_can_announce_winner():
    contract = deploy_election()
    tx = contract.registerVoter(accounts[2])
    tx.wait(1)
    tx1 = contract.payFee({"from": accounts[1], "value": 100})
    tx1.wait(1)
    contract.addCandidate(accounts[1], "Bob")
    tx3 = contract.startVote()
    tx3.wait(1)
    tx2 = contract.vote(accounts[1], {"from": accounts[2]})
    tx2.wait(1)
    contract.endVote()
    winner = contract.announceWinner()
    assert winner == accounts[1]

def test_can_withdraw_funds():
    contract = deploy_election()
    tx = contract.registerVoter(accounts[2])
    tx.wait(1)
    tx1 = contract.payFee({"from": accounts[1], "value": 100})
    tx1.wait(1)
    contract.addCandidate(accounts[1], "Bob")
    tx3 = contract.startVote()
    tx3.wait(1)
    tx2 = contract.vote(accounts[1], {"from": accounts[2]})
    tx2.wait(1)
    contract.endVote()
    tx4 = contract.withdrawRegistrationFunds()
    tx4.wait(1)
    assert contract.balanceOf() == 0