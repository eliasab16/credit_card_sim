# credit_card_sim

### Project stack:

Flutter -> Frontend (find the code under `/lib` directory)
Firebase Cloud Functions -> Backend (find the code under the `functions` directory)
Firebase Firestore -> Database


Note:
Although I separate the codebase into different files (inside `/lib`), I didn't setup a complete project structure with folders since the number of files is very small.


### Instructions:

To run it locally, you need to:
1) Install the dependencies with `npm i`
2) You might have to install other dependencies based on your environment
3) Navigate to `functions` directory, and run: `npm run build; firebase emulators:start --only functions`
4) From any `.dart` file in `/lib`, start the app with `Run > Run Without Debugging`

This will connect the project to the Firebase Emulator cloud functions. The databse (Firestore) will be the actual one I'm hosting. If you wish to also emulate the Firestor, you can run `firebase emulators:start`, but you will have to populate the Firebase with the initial data:

```
collection = 'accounts': {
    document = enter some string (account number/id): {
        available_credit: enter some number
        payable_balance: enter some number
        name: enter a string
        collection: {
            settled_transactions: leave empty (to be filled on the app)
            pending_transactions: leave empty
        }
    }
}
```