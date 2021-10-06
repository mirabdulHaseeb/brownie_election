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

def test_can_add_candidate():
    contract = deploy_election()
    tx = contract.payFee({"from": accounts[1], "value": 100})
    tx.wait(1)
    contract.addCandidate(accounts[1], "Bob")
    assert contract.getTotalCandidates() == 1
