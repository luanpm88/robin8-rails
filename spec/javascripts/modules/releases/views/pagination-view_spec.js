describe('Releases.PaginationView', function() {

  beforeEach(function() {
    this.model = new Robin.Models.Release();
    this.view = new Releases.PaginationView({ model: this.model });
  });

  it('should be defined', function() {
    expect(this.view).toBeDefined();
  });

  it('should have template', function() {
    expect(this.view.template).not.toBe(undefined);
  });

  it('should have pageOffset', function() {
    expect(this.view.pageOffset).not.toBe(undefined);
  });

  it('should have tagName', function() {
    expect(this.view.tagName).not.toBe(undefined);
  });

  it('should have attributes', function() {
    expect(this.view.attributes).not.toBe(undefined);
  });

  it('should have modelEvents', function() {
    expect(this.view.modelEvents).not.toBe(undefined);
  });

  it('should have events', function() {
    expect(this.view.events).not.toBe(undefined);
  });

  describe('templateHelpers', function() {
    beforeEach(function() {
      this.view.render(total_pages = 1);
    });
    
    it('should return leftEdge and rightEdge', function() {
      expect(this.view.templateHelpers()).toEqual(jasmine.objectContaining({'leftEdge': NaN, 'rightEdge': NaN}));
    });
  });

  describe('onBeforeRender', function() {
    beforeEach(function() {
      this.view.render(total_pages = 11, page = 2);
    });
    
    it('should set leftEdge and rightEdge', function() {
      expect(this.view.leftEdge).toEqual(NaN);
      expect(this.view.rightEdge).toEqual(NaN);
    });
  });

  describe('setPage', function() {
    it('should be defined', function() {
      expect(this.view.setPage).toBeDefined();
    });
  });
  
  describe('prevPage', function() {
    it('should be defined', function() {
      expect(this.view.prevPage).toBeDefined();
    });
  });
  
  describe('nextPage', function() {
    it('should be defined', function() {
      expect(this.view.nextPage).toBeDefined();
    });
  });
  
  describe('modelChanged', function() {
    it('should be defined', function() {
      expect(this.view.modelChanged).toBeDefined();
    });
  });
});

