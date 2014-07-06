# c3D Compatibility Documentation

c3D contracts have a standardized structure which is used by the c3D system to push and pull information to the contracts. By standardizing the interfaces, we are able to provide users and the DAO itself with unparalleled extensibility.

*Notes*: in the below documentation storage slots can hold different types of data. These are the types of data used in the documentation:

* (A) indicates this field points to a Storage address
* (B) indicates this field should be filled with a blob_id value
* (C) indicates this field should be filled with a contract address
* (B||C) indicate either (B) or (C) is accepted
* (K) indicates this field should be a (public) Address
* (I) indicates this field is an indicator and can take one of the values in []
* (V) indicates a value

## DOUG and c3D Contract Types

c3D contracts come in four flavors, each of which is connoted in the 0x10 storage slot:

1. 0x10 : (I) : 0x88554646AA -- Action Contract Only (no c3D data is attached to this contract)
2. 0x10 : (I) : 0x88554646AB -- c3D Content (data) Contract
3. 0x10 : (I) : 0x88554646BA -- c3D Structural (meta) Contract
4. 0x10 : (I) : 0x88554646BB -- Action Contract + (c3D Structural Contract ...?)

For the purposes of this documentation, `AA` contracts are simply indicators for the c3D system. c3D will take no action when a DAO link points to an `AA` contract.

Similarly `BB` contracts are mirrors of `BA` contracts and the c3D system will simply treat them as `BA` contracts. See below for further information on `AB` and `BA` contracts.

### BA Contracts -- c3D Structural Contracts

#### Top Level Contract Storage Slots

* 0x10 : (I)    : [0x88554646BA]
* 0x11 : (B||C) : pointer to an applicable datamodel.json
* 0x12 : (B||C) : pointer to an applicable set (or single) of UI file(s) structure
* 0x13 : (B||C) : content
* 0x14 : (C)    : Parent of this c3D contract
* 0x15 : (K)    : Owner of this c3D contract
* 0x16 : (C)    : Creator of this c3D contract
* 0x17 : (V)    : TimeStamp this c3D contract was created
* 0x18 : (I)    : Behaviour slot
* 0x19 : (A)    : Linked list start

#### Helpful Compatibility Definitions for Top Level Storage (primarily used by DOUGs ByLaws)

```lisp
(def 'indicator 0x10)
(def 'dmpointer 0x11)
(def 'UIpointer 0x12)
(def 'blob)
(def 'parent 0x14)
(def 'owner 0x15)
(def 'creator 0x16)
(def 'time 0x17)
(def 'LLstart 0x13)
```

#### Individual Entity Entries

* (linkID)+0 : (A)    : ContractTarget (for DOUG NameReg)
* (linkID)+1 : (A)    : Previous link
* (linkID)+2 : (A)    : Next link
* (linkID)+3 : (I)    : Type [ 0 => Contract || 1 => Blob || 2 => Datamodel Only ]
* (linkID)+4 : (V)    : Behaviour [0 => Ignore || 1 => Treat Normally || 2 => UI structure ||
                                        3 => Flash Notice || 4 => Datamodel list || 5 => Blacklist]
* (linkID)+5 : (B||C) : Content
* (linkID)+6 : (B||C) : Datamodel.json (*note*: if the content is a pointer to an `AB` contract this would typically be blank)
* (linkID)+7 : (B||C) : UI structure (*note*: if the content is a pointer to an `AB` contract this would typically be blank)
* (linkID)+8 : (V)    : Timestamp

#### Helpful Compatibility Definitions for Linked List Entries (primarily used by DOUGs ByLaws)

```lisp
(def 'nextslot (addr) (+ addr 2))
(def 'nextlink (addr) @@(+ addr 2))
(def 'prevslot (addr) (+ addr 1))
(def 'prevlink (addr) @@(+ addr 1))
(def 'typeslot (addr) (+ addr 3))
(def 'behaviourslot (addr) (+ addr 4))
(def 'dataslot (addr) (+ addr 5))
(def 'modelslot (addr) (+ addr 6))
(def 'UIlot (addr) (+ addr 7))
(def 'timeslot (addr) (+ addr 8))
```

### AB Contracts -- c3D Content Contract

#### Top Level Contract Storage Slots

* 0x10 : (I)    : [0x88554646AB]
* 0x11 : (B||C) : Datamodel.json
* 0x12 : (B||C) : UI structure
* 0x13 : (B)    : content
* 0x14 : (C)    : Parent
* 0x15 : (K)    : Owner
* 0x16 : (C)    : Creator
* 0x17 : (V)    : TimeStamp
* 0x18 : (I)    : Behaviour

#### Helpful Compatibility Definitions for Top Level Storage (primarily used by DOUGs ByLaws)

```lisp
(def 'indicator 0x10)
(def 'dmpointer 0x11)
(def 'UIpointer 0x12)
(def 'content 0x13)
(def 'parent 0x14)
(def 'owner 0x15)
(def 'creator 0x16)
(def 'time 0x17)
```

#### Individual Entries for BA Contracts

*Note*: BA contracts will never have linked lists as they are predominantly used to track meta information regarding individual content blobs.