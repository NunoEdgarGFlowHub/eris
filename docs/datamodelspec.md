## Overview

C3D and DOUG coordinate a data model and UI layer for individual contracts. For factories which are distributed with the Eris platform, the data model and UI are integrated at the factory level. This is because a factory will produce a given type of smart contract which will, in turn, have a specific data model. Other contracts as well will have their data models and UI files determined at the time they are deployed. You can find out more about how to handle the UI files in the appropriate ui-files.md file.

The data model which the Eris middlewear utilizes is contained in a json file. This json file is distributed by c3d and married to individual smart contracts within the DOUG layer. When a user wishes to interact with a smart contract, c3d will acquire the datamodel and the ui files and pass those to the Eris middlewear which will then serve the views to the user. The file **must** contain valid json or c3d will not be able to parse it and send the appropriate data to the Eris middlewear. Before passing the ui files to the view, c3d will assemble the datamodel into a usable series of API calls which may be used by the view. C3d will also parse the UI files using mustang templating format to build the view files with the appropriate data as described below.

Thus, the roll of the datamodel is to assemble the action calls and data required to render the view which the user can interact with. The top level of the JSON file contain two fields: actions and data. Each of these fields are covered in more detail below.

## Action Calls

Actions are given a name which will be matched by the Eris middlewear in order to conduct the action. These actions can be anything which is allowed by the smart contract and need not be confined to the action calls which are provided by the Eris platform out of the box.

Within each action there are five fields which c3d will parse.

1. `precall`: these are queries to the blockchain which may be required previous to sending the call (transaction). Precall queries have access to the current `$doug` and also to the contract in question via the `$this` keyword as well as any storage value within those contracts. Precall queries are passed as a json array and c3d will query each of the assembled queries in order. The result of each call will be stored in the `$precall` array for use by any queries or fields which follow the individual query (within the precall) or fields which precall (which is all of them). For example if the first precall query was to ask DOUG what the value of a particular key was then the call (or any later query within the precall or field) will have access to the result of that by referencing `$precall[0]`.
2. `call`: call is the transaction which is assembled by c3d and sent to the blockchain. Call transactions are passed as a json array to c3d. The first element of the array *must* be the destination of the transaction. The remainder of the array will be the data which is passed to the destination address. Call has access to any of the `$precall` array values via the `$precall` array. Since transactions do not (at this time) return any value there is nothing which the `call` field will store. The `call` field also has access to a special variable which is the `$blob` variable. This is a c3d file blob pointer which can be used to send to the blockchain.
3. `postcall`: these are queries to the blockchain which may be required after sending the call (transaction). All of the same rules as for precall exist here, save for the results of `$postcall` queries are stored in the `$postcall` array rather than the `$precall` array. Namely, while the `call`, `success`, and `result` fields do not have access to `$doug` and `$this`, the `$postcall` (as well as `$precall`) field does.
4. `success`: actions either succeed or fail. At this time there is no other answer which may be given to the view besides success=true or success=false. The view will have to determine what that means and how to react. The success field has access to the `$precall` array and the `$postcall` array only. Success is typically defined as a comparison operator (`==`, `!=`, `>`, `>=`, `<`, `<=`) matched against two of the array values from the `$precall` or `$postcall` arrays.
5. `result`: the result is passed, along with the result of the `success` field to the view layer at the completion of the action sequence. It is the `return` in most programming languages. The result has access to the `$precall` array, the `$postcall` array. The `result` field must be either a comparison operator (used the same as the `success` field) matched against two of the array values from the `$precall` or `$postcall` arrays OR a single value from one of the arrays. The result field is passed as an array and will return a JSON array with the individual results assembled.

### Returns of Action Calls

The view will receive a JSON formatted string from the Eris middlewear after the result of the action call which will be formatted like so:

```json
{
  "success":true, // or...false
  "result": [
              "0xaaaaaaaaaaaaa" // or... whatever the result is.
            ]
}
```

## View Data

Data fields are given a name which will be matched by c3d in order to assemble the view files from mustang templates in which they reside in their raw form. These data fields can be anything which are allowed by the smart contract and need not be confined to the view data which are provided by the Eris platform out of the box.

Data fields have a name and a query. That name can then be called by the mustache templates which c3d will prerender before passing to the middlewear for final rendering. Data fields have access to the following variables: `$doug` will point to the current doug; `$this` will point to the contract which holds the datamodel.

This is a work in progress and the details of data fields will be worked out in the very near term.