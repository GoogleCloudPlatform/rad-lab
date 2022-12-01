import { mockdeployments } from "@/mocks/api"
import { getAllDocuments, getDocsByField, saveDocument, deleteDocByFieldValue, deleteDocumentById } from "@/utils/Api_SeverSideCon"
import { db } from "@/pages/api/firebaseAdminConnection"


describe("Api ServerSide Connections util", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("get all documents : getAllDocuments", async () => {
    const get = jest.fn(() => ([
      {
        id: mockdeployments[0]?.id,
        data: () => (
          mockdeployments
        )
      }

    ]));
    const collection = jest.spyOn(db, 'collection')
      .mockReturnValue((({ get } as unknown) as any));

    let res = await getAllDocuments("deployments");
    expect(collection.mock.calls.length).toBe(1);
    expect(res.length).toBe(mockdeployments.length);
    collection.mockRestore();
  })

  it("get Documents By Field : getDocsByField", async () => {
    const get = jest.fn(() => ([
      {
        id: mockdeployments[0]?.id,
        data: () => (
          mockdeployments
        )
      }

    ]));
    const where = jest.fn(() => ({ get }))
    const collection = jest.spyOn(db, 'collection')
      .mockReturnValue((({ where } as unknown) as any));

    let res = await getDocsByField("deployments", "id", "5VL1UulH0eplVhv1IrY4");
    expect(collection.mock.calls.length).toBe(1);
    expect(res[0].id).toBe("b119nHZJEAIWKiIWC90g");
    collection.mockRestore();
  })

  it("save Documents in collection : saveDocument", async () => {

    const get = jest.fn(() => (
      {
        id: mockdeployments[0]?.id,
        data: () => (
          mockdeployments
        )
      }

    ));
    const set = jest.fn();
    const doc = jest.fn(() => {
      return {
        set,
        get
      };
    });
    const collection = jest.spyOn(db, 'collection')
      .mockReturnValue((({ doc } as unknown) as any));
    const mockbody = mockdeployments;
    let res = await saveDocument("deployments", mockbody, "b119nHZJEAIWKiIWC90g");
    expect(collection.mock.calls.length).toBe(2);
    collection.mockRestore();
  })

  it("delete Documents By Field value : deleteDocByFieldValue", async () => {
    const then = jest.fn(() => ([
      {
        id: mockdeployments[0]?.id,
        delete: () => (
          mockdeployments
        )
      }

    ]))
    const get = jest.fn(() => ({ then }));
    const where = jest.fn(() => ({ get }))
    const collection = jest.spyOn(db, 'collection')
      .mockReturnValue((({ where } as unknown) as any));
    let res = await deleteDocByFieldValue("deployments", "id", "b119nHZJEAIWKiIWC90g");
    expect(collection.mock.calls.length).toBe(1);
    collection.mockRestore();
  })

  it("delete Documents By id : deleteDocumentById", async () => {

    const doc = jest.fn((id) => (
      {
        delete: () => (id)
      }

    ))
    const collection = jest.spyOn(db, 'collection')
      .mockReturnValue((({ doc } as unknown) as any));
    let res = await deleteDocumentById("deployments", "b119nHZJEAIWKiIWC90g");
    expect(collection.mock.calls.length).toBe(1);
    collection.mockRestore();
  })
})
