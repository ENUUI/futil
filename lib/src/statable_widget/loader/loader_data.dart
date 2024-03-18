/// 组件加载状态
/// 控制页面状态
enum LoadingState {
  /// 初始状态
  init,

  /// 初次加载中
  loading,

  /// 数据加载成功之后再次加载中
  reloading,

  /// 数据加载成功切不为空，可渲染组件
  ready,

  /// 数据加载成功但为空
  empty,

  /// 数据加载出错
  error,

  /// 数据加载出错且数据不为空
  errorAndNotEmpty,
}

extension LoadingStateExtra on LoadingState {
  bool get isInit => this == LoadingState.init;

  bool get isError => this == LoadingState.error || this == LoadingState.errorAndNotEmpty;

  bool get isEmpty => this == LoadingState.empty;

  // 出错但有数据则优先展示内容, 用在分页加载数据时
  bool get isReady => this == LoadingState.ready || this == LoadingState.errorAndNotEmpty;

  bool get isLoading => this == LoadingState.loading;
}

class LoaderResult<T> {
  const LoaderResult({
    this.data,
    this.error,
    required this.state,
  });

  final T? data;
  final Object? error;
  final LoadingState state;

  LoaderResult<T> copy({T? data, Object? error, LoadingState? state}) {
    final nextState = state ?? this.state;
    return LoaderResult(
      data: data ?? this.data,
      error: nextState.isError ? (error ?? this.error) : null,
      state: nextState,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! LoaderResult) return false;
    return data == other.data && error == other.error && state == other.state;
  }

  @override
  int get hashCode => Object.hash(data.hashCode, error.hashCode, state.hashCode);
}

/// 空值刷新组件状态
enum LoaderProcessState {
  /// 首次加载之前占位
  none,

  /// 开始加载
  start,

  /// 加载成功
  success,

  /// 加载成功且无更多数据
  noMore,

  /// 加载失败
  failed,
}

class LoaderProcess {
  const LoaderProcess(this.status, this.refresh);

  final LoaderProcessState status;
  final bool refresh;

  @override
  bool operator ==(Object other) {
    if (other is! LoaderProcess) return false;
    return status == other.status && refresh == other.refresh;
  }

  @override
  int get hashCode => Object.hash(status.hashCode, refresh.hashCode);
}
