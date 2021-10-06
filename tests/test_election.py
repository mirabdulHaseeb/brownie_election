from brownie import accounts, Election
from scripts.deploy import deploy_election


def test_can_deploy():
    contract = deploy_election()
    assert contract.electionName() == "Dapp Elections"