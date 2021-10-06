from brownie import accounts, Election


def deploy_election():
    election = Election.deploy("Dapp Elections", {"from": accounts[0]})
    print("Deployed at address", election.address)
    return election

def main():
    return deploy_election()